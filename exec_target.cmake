include(CMakeParseArguments.cmake)

function(configure_exec_targets)
    cmake_parse_arguments(CET
                          ""
                          "PROJECT SOURCE_DIR SRC_SIR INCLUDE_DIR TEST_DIR"
                          ""
                          ${ARGN})

    if(NOT CET_PROJECT)
        message(WARNING "No project name specified, using CMAKE_PROJECT_NAME value ('${CMAKE_PROJECT_NAME}')")

        set(EXEC_TARGETS_PROJECT ${CMAKE_PROJECT_NAME} PARENT_SCOPE)
    else()
        set(EXEC_TARGETS_PROJECT ${CET_PROJECT} PARENT_SCOPE)
    endif()

    if(NOT CET_SOURCE_DIR)
        set(EXEC_TARGETS_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR} PARENT_SCOPE)
    else
        set(EXEC_TARGETS_SOURCE_DIR ${CET_SOURCE_DIR} PARENT_SCOPE)
    endif()

    if(NOT CET_SRC_DIR)
        set(EXEC_TARGETS_SRC_DIR ${EXEC_TARGETS_SOURCE_DIR}/src PARENT_SCOPE)
    else()
        set(EXEC_TARGETS_SRC_DIR ${CET_SRC_DIR} PARENT_SCOPE)
    endif()

    if(NOT CET_INCLUDE_DIR)
        set(EXEC_TARGETS_INCLUDE_DIR ${EXEC_TARGETS_SOURCE_DIR}/include PARENT_SCOPE)
    else()
        set(EXEC_TARGETS_INCLUDE_DIR ${CET_INCLUDE_DIR} PARENT_SCOPE)
    endif()


    if(NOT CET_TEST_DIR)
        set(EXEC_TARGETS_TEST_DIR ${EXEC_TARGETS_SOURCE_DIR}/test PARENT_SCOPE)
     else()
         set(EXEC_TARGETS_TEST_DIR ${CET_TEST_DIR} PARENT_SCOPE)
    endif()
endfunction()

function(exec_target)
    cmake_parse_arguments(ET
                          ""
                          "NAME PREFIX"
                          "COMPILE_OPTIONS FILES")

    if(NOT ET_NAME)
        message(FATAL_ERROR "No NAME specified for exec_target()")
    endif()



    # To see the headers in the solution...
    if(MSVC)
        generate_vs_source_groups(${ET_PREFIX}s ${EXEC_TARGETS_SOURCE_DIR}/${ET_PREFIX}s ${ET_PREFIX}_files)
        generate_vs_source_groups(include ${EXEC_TARGETS_INCLUDE_DIR} files)
    endif()

    add_executable(${ET_PREFIX}_${name} ${EXEC_TARGETS_SOURCE_DIR}/${ET_PREFIX}s/${name}.cpp
        ${${ET_PREFIX}_files} ${files} ${ET_FILES}
    )

    target_compile_options(${ET_PREFIX}_${name} PRIVATE 
        ${${EXEC_TARGETS_PROJECT}_GLOBAL_ALL_COMPILE_OPTIONS} 
        ${${EXEC_TARGETS_PROJECT}_${ET_PREFIX}_ALL_COMPILE_OPTIONS}
        $<$<CONFIG:Debug>:${${EXEC_TARGETS_PROJECT}_GLOBAL_DEBUG_COMPILE_OPTIONS}>
        $<$<CONFIG:Release>:${${EXEC_TARGETS_PROJECT}_GLOBAL_RELEASE_COMPILE_OPTIONS}> 
        $<$<CONFIG:Debug>:${${EXEC_TARGETS_PROJECT}_${ET_PREFIX}_DEBUG_COMPILE_OPTIONS}>
        $<$<CONFIG:Release>:${${EXEC_TARGETS_PROJECT}_${ET_PREFIX}_RELEASE_COMPILE_OPTIONS}>
        ${ET_COMPILE_OPTIONS}
    )

    target_include_directories(${ET_PREFIX}_${name} PRIVATE 
        ${${EXEC_TARGETS_PROJECT}_SOURCE_DIR}/include/ # ctti headers
        ${${EXEC_TARGETS_PROJECT}_SOURCE_DIR}/${ET_PREFIX}s/include/ # examples/tests extra includes
    )
endfunction()
