
function(install_gtestgmock)

    # Parse input arguments
    include(CMakeParseArguments)

    cmake_parse_arguments(""
                          ""
                          "GTEST_BASE_URL GMOCK_BASE_URL VERSION EXT GTEST_TARGET GMOCK_TARGET"
                          ""
                          ${ARGN})

    if(NOT _GTEST_BASE_URL)
        set(_GTEST_BASE_URL https://googletest.googlecode.com/files)
    endif()

    if(NOT _GMOCK_BASE_URL)
        set(_GMOCK_BASE_URL https://googlemock.googlecode.com/files)
    endif()

    if(NOT _VERSION)
        set(_VERSION 1.7.0)
    endif()

    if(NOT _EXT)
        set(_EXT .zip)
    endif()

    if(NOT _GTEST_LIB_TARGET)
        set(_GTEST_LIB_TARGET libgtest)
    endif()

    if(NOT _GMOCK_LIB_TARGET)
        set(_GMOCK_LIB_TARGET libgmock)
    endif()


    # We need thread support
    find_package(Threads REQUIRED)

    # Enable ExternalProject CMake module
    include(ExternalProject)

    # Download and install GoogleTest
    ExternalProject_Add(
        gtest
        URL ${_GTEST_BASE_URL}/gtest-${_VERSION}${_EXT}
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gtest
        # Disable install step
        INSTALL_COMMAND ""
    )

    # Create a libgtest target to be used as a dependency by test programs
    add_library(${_GTEST_LIB_TARGET} IMPORTED STATIC GLOBAL)
    add_dependencies(${_GTEST_LIB_TARGET} gtest)

    # Set gtest properties
    ExternalProject_Get_Property(gtest source_dir binary_dir)
    set_target_properties(${_GTEST_LIB_TARGET} PROPERTIES
        "IMPORTED_LOCATION" "${binary_dir}/libgtest.a"
        "IMPORTED_LINK_INTERFACE_LIBRARIES" "${CMAKE_THREAD_LIBS_INIT}"
        #    "INTERFACE_INCLUDE_DIRECTORIES" "${source_dir}/include"
    )
    # I couldn't make it work with INTERFACE_INCLUDE_DIRECTORIES
    include_directories("${source_dir}/include")

    # Download and install GoogleMock
    ExternalProject_Add(
        gmock
        URL ${_GMOCK_BASE_URL}/gmock-${_VERSION}${_EXT}
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gmock
        # Disable install step
        INSTALL_COMMAND ""
    )

    # Create a libgmock target to be used as a dependency by test programs
    add_library(${_GMOCK_LIB_TARGET} IMPORTED STATIC GLOBAL)
    add_dependencies(${_GMOCK_LIB_TARGET} gmock)

    # Set gmock properties
    ExternalProject_Get_Property(gmock source_dir binary_dir)
    set_target_properties(${_GMOCK_LIB_TARGET} PROPERTIES
        "IMPORTED_LOCATION" "${binary_dir}/libgmock.a"
        "IMPORTED_LINK_INTERFACE_LIBRARIES" "${CMAKE_THREAD_LIBS_INIT}"
        #    "INTERFACE_INCLUDE_DIRECTORIES" "${source_dir}/include"
    )
    # I couldn't make it work with INTERFACE_INCLUDE_DIRECTORIES
    include_directories("${source_dir}/include")

    set(GTEST_LIB_TARGET ${_GTEST_LIB_TARGET} PARENT_SCOPE)
    set(GMOCK_LIB_TARGET ${_GMOCK_LIB_TARGET} PARENT_SCOPE)
endfunction()

include(${CMAKE_CURRENT_LIST_DIR}/exec_target.cmake)

function(gmock_test_target)
    if((NOT GTEST_LIB_TARGET) OR (NOT GMOCK_LIB_TARGET))
        message(FATAL_ERROR "GMock library not configured! Invoke install_gtestgmock() first.")
    endif()

    parse_exec_target_args(${ARGN} PREFIX test)

    if(NOT ET_TARGET_OUT)
        exec_target(${ARGN} PREFIX test TARGET_OUT __exec_target)
    else()
        exec_target(${ARGN} PREFIX test)
        set(__exec_target ${${ET_TARGET_OUT}})
    endif()
    
    target_link_libraries(${__exec_target} ${GTEST_LIB_TARGET} ${GMOCK_LIB_TARGET})

    add_test(NAME ${ET_NAME} COMMAND ${__exec_target})
endfunction()
