include(CMakeParseArguments)

function(__print_exec_targets_config)

    message(STATUS "exec_target() configured:")
    message(STATUS "=========================")
    message(STATUS " - PROJECT: ${EXEC_TARGETS_PROJECT}")
    message(STATUS " - SOURCE DIR: ${EXEC_TARGETS_SOURCE_DIR}")
    message(STATUS " - SRC DIR: ${EXEC_TARGETS_SRC_DIR}")
    message(STATUS " - INCLUDE DIR: ${EXEC_TARGETS_INCLUDE_DIR}")
    message(STATUS " - TEST DIR: ${EXEC_TARGETS_TEST_DIR}")

endfunction()

function(configure_exec_targets)
    set(options)
    set(oneValueArgs PROJECT SOURCE_DIR SRC_DIR INCLUDE_DIR TEST_DIR)
    set(multiValueArgs)
    cmake_parse_arguments(CET "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT CET_PROJECT)
        set(EXEC_TARGETS_PROJECT "${CMAKE_PROJECT_NAME}" CACHE )
    else()
        set(EXEC_TARGETS_PROJECT "${CET_PROJECT}" PARENT_SCOPE) 
    endif()

    if(NOT CET_SOURCE_DIR)
        message("NO SOURCE! ${CMAKE_SOURCE_DIR}")
        set(SOURCE_DIR "${CMAKE_SOURCE_DIR}")
    else()
        message("SOURCE!")
        set(SOURCE_DIR "${CET_SOURCE_DIR}") 
    endif()

    if(NOT CET_SRC_DIR)
        set(EXEC_TARGETS_SRC_DIR "${SOURCE_DIR}/src" PARENT_SCOPE)
    else()
        set(EXEC_TARGETS_SRC_DIR "${CET_SRC_DIR}" PARENT_SCOPE)
    endif()

    if(NOT CET_INCLUDE_DIR)
        set(EXEC_TARGETS_INCLUDE_DIR "${SOURCE_DIR}/include" PARENT_SCOPE)
    else()
        set(EXEC_TARGETS_INCLUDE_DIR "${CET_INCLUDE_DIR}" PARENT_SCOPE)
    endif()


    if(NOT CET_TEST_DIR)
        set(EXEC_TARGETS_TEST_DIR "${SOURCE_DIR}/test" PARENT_SCOPE)
     else()
         set(EXEC_TARGETS_TEST_DIR "${CET_TEST_DIR}" PARENT_SCOPE)
    endif()

    set(EXEC_TARGETS_SOURCE_DIR "${SOURCE_DIR}" PARENT_SCOPE)

endfunction()

function(exec_target)
    set(options)
    set(oneValueArgs NAME PREFIX)
    set(multiValueArgs COMPILE_OPTIONS)
    cmake_parse_arguments(ET "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    __print_exec_targets_config()

    if(NOT ET_NAME)
        message(FATAL_ERROR "No NAME specified for exec_target()")
    endif()

    if(NOT ET_PREFIX)
        message(FATAL_ERROR "No PREFIX specified for exec_target()")
    endif()


    # To see the headers in the solution...
    if(MSVC)
        generate_vs_source_groups(${ET_PREFIX}s ${EXEC_TARGETS_SOURCE_DIR}/${ET_PREFIX}s ${ET_PREFIX}_files)
        generate_vs_source_groups(include ${EXEC_TARGETS_INCLUDE_DIR} files)
    endif()

    add_executable(${ET_PREFIX}_${ET_NAME} ${EXEC_TARGETS_SOURCE_DIR}/${ET_PREFIX}s/${ET_NAME}.cpp
        ${${ET_PREFIX}_files} ${files} ${ET_FILES}
    )

    target_compile_options(${ET_PREFIX}_${ET_NAME} PRIVATE 
        ${${EXEC_TARGETS_PROJECT}_GLOBAL_ALL_COMPILE_OPTIONS} 
        ${${EXEC_TARGETS_PROJECT}_${ET_PREFIX}_ALL_COMPILE_OPTIONS}
        $<$<CONFIG:Debug>:${${EXEC_TARGETS_PROJECT}_GLOBAL_DEBUG_COMPILE_OPTIONS}>
        $<$<CONFIG:Release>:${${EXEC_TARGETS_PROJECT}_GLOBAL_RELEASE_COMPILE_OPTIONS}> 
        $<$<CONFIG:Debug>:${${EXEC_TARGETS_PROJECT}_${ET_PREFIX}_DEBUG_COMPILE_OPTIONS}>
        $<$<CONFIG:Release>:${${EXEC_TARGETS_PROJECT}_${ET_PREFIX}_RELEASE_COMPILE_OPTIONS}>
        ${ET_COMPILE_OPTIONS}
    )

    target_include_directories(${ET_PREFIX}_${ET_NAME} PRIVATE 
        ${EXEC_TARGETS_INCLUDE_DIR}
        ${EXEC_TARGETS_SOURCE_DIR}/${ET_PREFIX}/include/ # examples/tests extra includes
    )
endfunction()
