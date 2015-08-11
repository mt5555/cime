# - Try to find NetCDF
#
# This can be controlled by setting the NetCDF_DIR (or, equivalently, the 
# NETCDF environment variable), or NetCDF_<lang>_DIR CMake variables, where
# <lang> is the COMPONENT language one needs.
#
# Once done, this will define:
#
#   NetCDF_<lang>_FOUND        (BOOL) - system has NetCDF
#   NetCDF_<lang>_IS_SHARED    (BOOL) - whether library is shared/dynamic
#   NetCDF_<lang>_INCLUDE_DIR  (PATH) - Location of the C header file
#   NetCDF_<lang>_INCLUDE_DIRS (LIST) - the NetCDF include directories
#   NetCDF_<lang>_LIBRARY      (FILE) - Path to the C library file
#   NetCDF_<lang>_LIBRARIES    (LIST) - link these to use NetCDF
#   NetCDF_<lang>_DEFINITIONS  (LIST) - preprocessor macros to use with NetCDF
#   NetCDF_<lang>_OPTIONS      (LIST) - compiler options to use NetCDF
#
# The available COMPONENTS are: C, Fortran
# If no components are specified, it assumes only C
include (LibFindLibraryMacros)

set (NetCDF_VALID_COMPONENTS C Fortran)

if (NOT NetCDF_FIND_COMPONENTS)
    set (NetCDF_FIND_COMPONENTS C)
endif ()

set (NetCDF_FIND_VALID_COMPONENTS)
foreach (comp IN LISTS NetCDF_FIND_COMPONENTS)
    if (";${NetCDF_VALID_COMPONENTS};" MATCHES ";${comp};")
        list (APPEND NetCDF_FIND_VALID_COMPONENTS ${comp})
    endif ()
endforeach ()

set (NetCDF_C_INCLUDE_NAMES netcdf.h)
set (NetCDF_Fortran_INCLUDE_NAMES netcdf.mod netcdf.inc)

set (NetCDF_C_LIBRARY_NAMES netcdf)
set (NetCDF_Fortran_LIBRARY_NAMES netcdff)

foreach (comp IN LISTS NetCDF_FIND_VALID_COMPONENTS)

    if (NOT NetCDF_${comp}_FOUND)

        if (MPI_${comp}_FOUND)
            set (NetCDF_${comp}_INCLUDE_HINTS ${MPI_${comp}_INCLUDE_PATH})
            set (NetCDF_${comp}_LIBRARY_HINTS)
            foreach (lib IN LISTS ${MPI_${comp}_LIBRARIES})
                get_filename_component (libdir ${lib} PATH)
                list (APPEND NetCDF_${comp}_LIBRARY_HINTS ${libdir})
                unset (libdir)
            endforeach ()
        endif ()
    
        find_package_component(NetCDF COMPONENT ${comp}
                               INCLUDE_NAMES ${NetCDF_${comp}_INCLUDE_NAMES}
                               INCLUDE_HINTS ${NetCDF_${comp}_INCLUDE_HINTS}
                               LIBRARY_NAMES ${NetCDF_${comp}_LIBRARY_NAMES}
                               LIBRARY_HINTS ${NetCDF_${comp}_LIBRARY_HINTS})
        
        # Handle Dependencies, if static
        if (NOT NetCDF_${comp}_IS_SHARED)
        
            if (comp STREQUAL C)
            
                # DEPENDENCY: HDF5
                find_package (HDF5 COMPONENTS C HL)
                if (HDF5_FOUND)
                    list (APPEND NetCDF_C_INCLUDE_DIRS ${HDF5_INCLUDE_DIRS})
                    list (APPEND NetCDF_C_LIBRARIES ${HDF5_C_LIBRARIES}
                                                    ${HDF5_HL_LIBRARIES})
                endif ()
                
            elseif (comp STREQUAL Fortran)
            
                # DEPENDENCY: HDF5
                find_package (HDF5 COMPONENTS Fortran Fortran_HL)
                if (NetCDF_C_FOUND)
                    list (APPEND NetCDF_Fortran_INCLUDE_DIRS ${HDF5_Fortran_INCLUDE_DIRS})
                    list (APPEND NetCDF_Fortran_LIBRARIES ${HDF5_Fortran_LIBRARIES}
                                                          ${HDF5_Fortran_HL_LIBRARIES})
                endif ()
    
            endif ()
    
        endif ()
        
    endif ()
    
endforeach ()
