// aqflush: LD_PRELOAD shim for running Hyprland (aquamarine wayland backend) nested.
// Problem: aquamarine queues its first xdg_surface commit but does not flush the parent connection
// until an event arrives; the first buffer attach then reaches the parent before the configure
// handshake -> "xdg_surface#3: error 3: xdg_surface has never been configured" and the parent drops us.
// Fix: remember wl_displays this process connects to and flush them before every event-loop wait.
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <signal.h>
#include <pthread.h>
#include <sys/epoll.h>
struct wl_display;
static struct wl_display *disp[8]; static int ndisp; static pthread_mutex_t mu = PTHREAD_MUTEX_INITIALIZER;
static int (*real_flush)(struct wl_display*);
static void remember(struct wl_display *d){ if(!d) return; pthread_mutex_lock(&mu); if(ndisp<8) disp[ndisp++]=d; pthread_mutex_unlock(&mu); }
static void flush_all(void){ if(!ndisp) return; if(!real_flush) real_flush=dlsym(RTLD_DEFAULT,"wl_display_flush"); if(!real_flush) return;
  pthread_mutex_lock(&mu); for(int i=0;i<ndisp;i++) real_flush(disp[i]); pthread_mutex_unlock(&mu); }
struct wl_display *wl_display_connect(const char *name){ static struct wl_display *(*r)(const char*); if(!r) r=dlsym(RTLD_NEXT,"wl_display_connect");
  struct wl_display *d=r(name); remember(d); return d; }
struct wl_display *wl_display_connect_to_fd(int fd){ static struct wl_display *(*r)(int); if(!r) r=dlsym(RTLD_NEXT,"wl_display_connect_to_fd");
  struct wl_display *d=r(fd); remember(d); return d; }
void wl_display_disconnect(struct wl_display *d){ static void (*r)(struct wl_display*); if(!r) r=dlsym(RTLD_NEXT,"wl_display_disconnect");
  pthread_mutex_lock(&mu); for(int i=0;i<ndisp;i++) if(disp[i]==d){ disp[i]=disp[--ndisp]; break; } pthread_mutex_unlock(&mu); r(d); }
int epoll_wait(int e, struct epoll_event *ev, int n, int t){ static int (*r)(int,struct epoll_event*,int,int); if(!r) r=dlsym(RTLD_NEXT,"epoll_wait"); flush_all(); return r(e,ev,n,t); }
int epoll_pwait(int e, struct epoll_event *ev, int n, int t, const sigset_t *s){ static int (*r)(int,struct epoll_event*,int,int,const sigset_t*); if(!r) r=dlsym(RTLD_NEXT,"epoll_pwait"); flush_all(); return r(e,ev,n,t,s); }
__attribute__((constructor)) static void init(void){ unsetenv("LD_PRELOAD"); } // don't leak into Hyprland's children
