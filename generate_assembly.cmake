include(CMakeParseArguments)

function(generate_assembly)
    set(options NO_PLURAL_PREFIX)
    set(oneValueArgs TARGET FILE PREFIX OUTPUT_PATH)
    set(multiValueArgs)
    cmake_parse_arguments(GA "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT GA_OUTPUT_PATH)
        set(GA_OUTPUT_PATH ${CMAKE_BINARY_DIR}/listings)
    endif()

    set(GA_OUTPUT_PATH ${GA_OUTPUT_PATH}/${GA_TARGET}/${CMAKE_BUILD_TYPE})

    if(NOT ${GA_OUTPUT_PATH})
        file(MAKE_DIRECTORY ${GA_OUTPUT_PATH})
    endif()

    if(MSVC)
      target_compile_options(${GA_TARGET} PRIVATE "/Fa${GA_OUTPUT_PATH}/${GA_FILE}.asm" /FA)
    else()
        if(NOT GA_PREFIX)
            set(working_directory ${CMAKE_BINARY_DIR})
        else()
            if(NOT GA_NO_PLURAL_PREFIX)
                set(GA_PREFIX ${GA_PREFIX}s)
            endif()
            
            set(working_directory ${CMAKE_BINARY_DIR}/${GA_PREFIX})
        endif()

        message(INFO "[GENERATE_ASSEMBLY] Invoking make ${GA_FILE}.s at directory ${working_directory}")

        add_custom_command(TARGET ${GA_TARGET}
                           POST_BUILD
                           COMMAND make ARGS ${GA_FILE}.s
                           WORKING_DIRECTORY ${working_directory}
                           COMMAND ${CMAKE_COMMAND} -E copy
                               "${working_directory}/CMakeFiles/${GA_TARGET}.dir/${GA_FILE}.cpp.s"
                               "${GA_OUTPUT_PATH}/${GA_FILE}.s"
                           WORKING_DIRECTORY ${working_directory})
    endif()
endfunction()