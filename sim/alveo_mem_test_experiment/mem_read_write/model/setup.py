from setuptools import setup
from setuptools.extension import Extension

from Cython.Build import cythonize
import os

CPP_MODEL_HOME = os.getenv('CPP_MODEL_HOME')
COMMON_HOME = os.getenv('COMMON_HOME')
DEBUG          = os.getenv('DEBUG')

mrw_extension   = Extension("mem_read_write_model",
                      sources=["mem_read_write_model.pyx"],
                      include_dirs = [str(CPP_MODEL_HOME)+"/include/"],
                      define_macros=[("DEBUG",str(DEBUG))]
                      )

# setting compilation parameters for read_master_model python extension object
rm_extension    = Extension("read_master_model",
                      sources=["../../common/read_master_model.pyx"],
                      include_dirs = [str(COMMON_HOME)+"/include/"],
                      define_macros=[("DEBUG",str(DEBUG))]
                      )

# setting compilation parameters for write_master_model python extension object
wm_extension    = Extension("write_master_model",
                      sources=["../../common/write_master_model.pyx"],
                      include_dirs = [str(COMMON_HOME)+"/include/"],
                      define_macros=[("DEBUG",str(DEBUG))]
                      )


extensions = [
    mrw_extension, 
    rm_extension, 
    wm_extension
]
setup(
    ext_modules=cythonize(extensions, language_level = "3")
)