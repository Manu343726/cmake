
function(install_gtestgmock)

    # Parse input arguments
    include(CMakeParseArguments)

    cmake_parse_arguments(""
                          ""
                          "GTEST_BASE_URL GMOCK_BASE_URL VERSION EXT GTEST_LIB_TARGET GMOCK_LIB_TARGET GTEST_MAIN_TARGET GMOCK_MAIN_TARGET"
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
        set(_GTEST_LIB_TARGET libgtest_v${_VERSION})
    endif()

    if(NOT _GMOCK_LIB_TARGET)
        set(_GMOCK_LIB_TARGET libgmock_v${_VERSION})
    endif()

    if(NOT _GTEST_MAIN_TARGET)
        set(_GTEST_MAIN_TARGET libgtest_main_v${_VERSION})
    endif()

    if(NOT _GMOCK_MAIN_TARGET)
        set(_GMOCK_MAIN_TARGET libgmock_main_v${_VERSION})
    endif()

    if(TARGET ${_GMOCK_LIB_TARGET})
        set(GTEST_LIB_TARGET ${_GTEST_LIB_TARGET} PARENT_SCOPE)
        set(GMOCK_LIB_TARGET ${_GMOCK_LIB_TARGET} PARENT_SCOPE)
        set(GTEST_MAIN_TARGET ${_GTEST_MAIN_TARGET} PARENT_SCOPE)
        set(GMOCK_MAIN_TARGET ${_GMOCK_MAIN_TARGET} PARENT_SCOPE)
    
        return()
    endif()

    if(MSVC)
        if(NOT CMAKE_BUILD_TYPE)
            set(CMAKE_BUILD_TYPE Debug)
        endif()

        message(WARNING "GTest/GMock library locations guessed from CMAKE_BUILD_TYPE variable (${CMAKE_BUILD_TYPE}), which may not match the current configuration of Visual Studio inside IDE")

        set(GTEST_LIB_IMPORTED_LOCATION ${CMAKE_BUILD_TYPE}/gtest.lib)
        set(GMOCK_LIB_IMPORTED_LOCATION ${CMAKE_BUILD_TYPE}/gmock.lib)
        set(GTEST_MAIN_LIB_IMPORTED_LOCATION ${CMAKE_BUILD_TYPE}/gtest_main.lib)
        set(GMOCK_MAIN_LIB_IMPORTED_LOCATION ${CMAKE_BUILD_TYPE}/gmock_main.lib)
    else()
        set(GTEST_LIB_IMPORTED_LOCATION libgtest.a)
        set(GMOCK_LIB_IMPORTED_LOCATION libgmock.a)
        set(GTEST_MAIN_LIB_IMPORTED_LOCATION libgtest_main.a)
        set(GMOCK_MAIN_LIB_IMPORTED_LOCATION libgmock_main.a)
    endif()

    message(STATUS "Setting up gmock ${_VERSION}...")

    # We need thread support
    find_package(Threads REQUIRED)

    # Enable ExternalProject CMake module
    include(ExternalProject)

    # Download and install GoogleTest
    ExternalProject_Add(
        gtest_external_project
        URL ${_GTEST_BASE_URL}/gtest-${_VERSION}${_EXT}
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gtest
        # Disable install step
        INSTALL_COMMAND ""
        CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
               -Dgtest_force_shared_crt=ON
        EXCLUDE_FROM_ALL TRUE
    )

    # Create a libgtest target to be used as a dependency by test programs
    add_library(gtest_imported IMPORTED STATIC GLOBAL)
    add_dependencies(gtest_imported gtest_external_project)


    # Set gtest properties
    ExternalProject_Get_Property(gtest_external_project source_dir binary_dir)
    set_target_properties(gtest_imported PROPERTIES
        "IMPORTED_LOCATION" "${binary_dir}/${GTEST_LIB_IMPORTED_LOCATION}"
        "IMPORTED_LINK_INTERFACE_LIBRARIES" "${CMAKE_THREAD_LIBS_INIT}"
        "INTERFACE_INCLUDE_DIRECTORIES" "${source_dir}/include"
        EXCLUDE_FROM_ALL TRUE
    )

    # Create GTest default main library
    add_library(gtest_main_imported IMPORTED STATIC GLOBAL)
    set_target_properties(gtest_main_imported PROPERTIES
        "IMPORTED_LOCATION" "${binary_dir}/${GTEST_MAIN_LIB_IMPORTED_LOCATION}"
        IMPORTED_LINK_INTERFACE_LIBRARIES ${_GTEST_LIB_TARGET}
        EXCLUDE_FROM_ALL TRUE
    )

    add_library(${_GTEST_LIB_TARGET} INTERFACE)
    target_link_libraries(${_GTEST_LIB_TARGET} INTERFACE gtest_imported)
    add_library(${_GTEST_MAIN_TARGET} INTERFACE)
    target_link_libraries(${_GTEST_MAIN_TARGET} INTERFACE gtest_main_imported)


    # Download and install GoogleMock
    ExternalProject_Add(
        gmock_external_project
        URL ${_GMOCK_BASE_URL}/gmock-${_VERSION}${_EXT}
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gmock
        # Disable install step
        INSTALL_COMMAND ""
        CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
               -Dgtest_force_shared_crt=ON
               ${MSVC_CRT_DYNAMIC}
        EXCLUDE_FROM_ALL TRUE
    )

    # Create a libgmock target to be used as a dependency by test programs
    add_library(gmock_imported IMPORTED STATIC GLOBAL)
    add_dependencies(gmock_imported gmock_external_project)

    # Set gmock properties
    ExternalProject_Get_Property(gmock_external_project source_dir binary_dir)
    set_target_properties(gmock_imported PROPERTIES
        "IMPORTED_LOCATION" "${binary_dir}/${GMOCK_LIB_IMPORTED_LOCATION}"
        "IMPORTED_LINK_INTERFACE_LIBRARIES" "${CMAKE_THREAD_LIBS_INIT}"
        "INTERFACE_INCLUDE_DIRECTORIES" "${source_dir}/include"
        EXCLUDE_FROM_ALL TRUE
    )

    # Create GMock default main library
    add_library(gmock_main_imported IMPORTED STATIC GLOBAL)
    set_target_properties(gmock_main_imported PROPERTIES
        "IMPORTED_LOCATION" "${binary_dir}/${GMOCK_MAIN_LIB_IMPORTED_LOCATION}"
        IMPORTED_LINK_INTERFACE_LIBRARIES ${_GMOCK_LIB_TARGET}
    )

    add_library(${_GMOCK_LIB_TARGET} INTERFACE)
    target_link_libraries(${_GMOCK_LIB_TARGET} INTERFACE gmock_imported)
    add_library(${_GMOCK_MAIN_TARGET} INTERFACE)
    target_link_libraries(${_GMOCK_MAIN_TARGET}  INTERFACE gmock_main_imported)

    set(GTEST_LIB_TARGET ${_GTEST_LIB_TARGET} PARENT_SCOPE)
    set(GMOCK_LIB_TARGET ${_GMOCK_LIB_TARGET} PARENT_SCOPE)
    set(GTEST_MAIN_TARGET ${_GTEST_MAIN_TARGET} PARENT_SCOPE)
    set(GMOCK_MAIN_TARGET ${_GMOCK_MAIN_TARGET} PARENT_SCOPE)

    target_link_libraries(${_GMOCK_LIB_TARGET} INTERFACE ${_GTEST_LIB_TARGET})
endfunction()

include(${CMAKE_CURRENT_LIST_DIR}/exec_target.cmake)

function(gmock_test_target)
    cmake_parse_arguments(GMOCK_TEST "CUSTOM_MAIN" "" "" ${ARGN})

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
    
    if(GMOCK_TEST_CUSTOM_MAIN)
        target_link_libraries(${__exec_target} ${GTEST_LIB_TARGET} ${GMOCK_LIB_TARGET})
    else()
        target_link_libraries(${__exec_target} ${GTEST_LIB_TARGET} ${GMOCK_LIB_TARGET} ${GMOCK_MAIN_TARGET})
    endif()

    add_test(NAME ${ET_NAME} COMMAND ${__exec_target})
endfunction()
