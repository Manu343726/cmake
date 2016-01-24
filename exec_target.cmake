include(CMakeParseArguments)
include(cmake/generate_assembly)
include(cmake/custom_properties)

function(__print_exec_targets_config)
    message(STATUS "Executable target '${ET_PREFIX}_${ET_NAME}' (from ${ET_PREFIX}s/${ET_NAME}${ET_EXT})")
endfunction()

function(configure_exec_targets)
    set(options RUN_ALL)
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

macro(parse_exec_target_args)
    set(options RUN ASSEMBLY)
    set(oneValueArgs NAME PREFIX TARGET_OUT EXT)
    set(multiValueArgs COMPILE_OPTIONS)
    cmake_parse_arguments(ET "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ET_NAME)
        message(FATAL_ERROR "No NAME specified for exec_target()")
    endif()

    if(NOT ET_EXT)
        set(ET_EXT .cpp)
    endif()

    if(NOT ET_PREFIX)
        message(FATAL_ERROR "No PREFIX specified for exec_target()")
    endif()
endmacro()

function(exec_target)
    parse_exec_target_args(${ARGN})

    # To see the headers in the solution...
    if(MSVC)
        generate_vs_source_groups(${ET_PREFIX}s ${EXEC_TARGETS_SOURCE_DIR}/${ET_PREFIX}s ${ET_PREFIX}_files)
        generate_vs_source_groups(include ${EXEC_TARGETS_INCLUDE_DIR} headers)

        foreach(header ${headers})
            set_source_file_custom_property("${header}" VS_SOURCEGROUPS_HEADER TRUE)
        endforeach()
    endif()

    add_executable(${ET_PREFIX}_${ET_NAME} ${EXEC_TARGETS_SOURCE_DIR}/${ET_PREFIX}s/${ET_NAME}${ET_EXT}
        ${headers} ${ET_FILES}
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

    if(ET_ASSEMBLY)
        generate_assembly(TARGET ${ET_PREFIX}_${ET_NAME} FILE ${ET_NAME} PREFIX ${ET_PREFIX})
    endif()

    if(ET_RUN)
        if(EXEC_TARGETS_RUN_ALL)
            set(run_all ALL)
        endif()

        if(MSVC)
            set(banner "===================================")
        endif()

        add_custom_target(
            run_${ET_PREFIX}_${ET_NAME} ${run_all} 
            COMMAND ${CMAKE_COMMAND} -E echo "${banner}"
            COMMAND ${ET_PREFIX}_${ET_NAME} ${ET_RUN_ARGS}
            COMMAND ${CMAKE_COMMAND} -E echo "${banner}"
            DEPENDS ${ET_PREFIX}_${ET_NAME}
            COMMENT "Running ${ET_NAME} ${ET_PREFIX}..."
        )

        if(NOT (TARGET run_${EXEC_TARGETS_PROJECT}))
            add_custom_target(run_${EXEC_TARGETS_PROJECT})
        endif()

        add_dependencies(run_${EXEC_TARGETS_PROJECT} run_${ET_PREFIX}_${ET_NAME})
    endif()

    if(ET_TARGET_OUT)
        set(${ET_TARGET_OUT} ${ET_PREFIX}_${ET_NAME} PARENT_SCOPE)
    endif()

    __print_exec_targets_config()
endfunction()

function(test_target)
    parse_exec_target_args(${ARGN} PREFIX test)

    if(NOT ET_TARGET_OUT)
        exec_target(${ARGN} PREFIX test TARGET_OUT __exec_target)
    else()
        exec_target(${ARGN} PREFIX test)
        set(__exec_target ${${ET_TARGET_OUT}})
    endif()
    
    add_test(NAME ${ET_NAME} COMMAND ${__exec_target})
endfunction()
