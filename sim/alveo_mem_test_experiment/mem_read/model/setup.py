from setuptools import setup
from setuptools.extension import Extension

from Cython.Build import cythonize
import os

CPP_MODEL_HOME = os.getenv('CPP_MODEL_HOME')
COMMON_HOME = os.getenv('COMMON_HOME')
DEBUG          = os.getenv('DEBUG')

mr_extension = Extension("mem_read_model",
                      sources=["mem_read_model.pyx"],
                      include_dirs = [str(CPP_MODEL_HOME)+"/include/"],
                      define_macros=[("DEBUG",str(DEBUG))]
                      )

rm_extension = Extension("read_master_model",
                      sources=["../../common/read_master_model.pyx"],
                      include_dirs = [str(COMMON_HOME)+"/include/"],
                      define_macros=[("DEBUG",str(DEBUG))]
                      )


extensions = [mr_extension, rm_extension]
setup(
    ext_modules=cythonize(extensions)
)