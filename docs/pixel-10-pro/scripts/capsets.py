import os,fcntl,ctypes,struct
fd=os.open('/dev/dri/renderD128',os.O_RDWR)
def getparam(p):
    v=ctypes.c_uint64(0); fcntl.ioctl(fd,(3<<30)|(16<<16)|(ord('d')<<8)|0x43,struct.pack('QQ',p,ctypes.addressof(v))); return v.value
names={1:'virgl',2:'virgl2',3:'gfxstream-vulkan',4:'venus',5:'cross-domain',6:'drm',7:'gfxstream-magma',8:'gfxstream-gles',9:'gfxstream-composer'}
m=getparam(7)
print('VIRTGPU_PARAM_SUPPORTED_CAPSET_IDs = 0x%x -> %s'%(m,[names.get(i,i) for i in range(64) if m>>i&1]))
