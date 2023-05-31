function(find_system_Cairo)
  message(STATUS "Looking for Cairo in the system")
  find_package(Cairo)
  if(Cairo_FOUND)
    add_dependencies(${VM_LIBRARY_NAME} Cairo::Cairo)
  else()
    message(STATUS "Cairo not found.")
  endif()
  set(Cairo_FOUND ${Cairo_FOUND} PARENT_SCOPE)
endfunction()

function(download_Cairo)
  if (WIN)
    If(${CMAKE_SYSTEM_PROCESSOR} MATCHES "ARM64")
      add_third_party_dependency("pixman-0.40.0")
      add_third_party_dependency("cairo-1.16.0")
      add_third_party_dependency("libpng-1.6.37")
    else()
      # X86 and X86_64
      add_third_party_dependency("pixman-0.40.0")
      add_third_party_dependency("cairo-1.17.4")
      add_third_party_dependency("libpng-1.6.37")
    endif()
  elseif(OSX)
    If(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64")
      add_third_party_dependency("pixman-0.40.0")
      add_third_party_dependency("cairo-1.17.4")
      add_third_party_dependency("libpng-1.6.37")
    else()
      add_third_party_dependency("pixman-0.40.0")
      add_third_party_dependency("cairo-1.17.4")
      add_third_party_dependency("libpng-1.6.37")
    endif()
  else() #Linux
    If(${CMAKE_SYSTEM_PROCESSOR} MATCHES "armv7l" OR (${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64"))
      add_third_party_dependency("pixman-0.40.0")
      add_third_party_dependency("cairo-1.16.0")
      add_third_party_dependency("libpng-1.6.37")
    else()
      add_third_party_dependency("pixman-0.40.0")
      add_third_party_dependency("cairo-1.17.4")
      add_third_party_dependency("libpng-1.6.37")
    endif()  
  endif()
endif()
endFunction()

function(build_Cairo)
  message(STATUS "Building Cairo")

endfunction()

if (BUILD_BUNDLE)
  #Only get Freetype if required
  if(PHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES)
    #Download Freetype binaries directly
    download_Freetype()
  else()
    #Look for Freetype in the system, then build or download if possible
    find_system_Freetype()
    if(NOT Freetype_FOUND)
        build_Freetype()
    endif()
  endif()
endif()



if (BUILD_BUNDLE)
  #Only get Cairo if required
  if(PHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES)
    #Download Cairo binaries directly
    download_Cairo()
  else()
    #Look for Cairo in the system, then build or download if possible
    find_system_Cairo()
    if(NOT Cairo_FOUND)
        build_Cairo()
    endif()
  endif()
endif()
