
include(cmake/cmakepp)

set(ENABLE_CUSTOM_PROPERTIES LABELS)


function(get_target_custom_properties TARGET)
    string(REGEX REPLACE " " "-" TARGET_ID "${TARGET}")

    is_map(TARGET_${TARGET_ID}_CUSTOM_PROPERTIES)
    ans(isset)

    if(NOT isset)
        map_new(TARGET_${TARGET_ID}_CUSTOM_PROPERTIES)
    endif()

    map_foreach("${TARGET_${TARGET_ID}_CUSTOM_PROPERTIES}" "(k,v)-> message($k $v)")
    return(TARGET_${TARGET_ID}_CUSTOM_PROPERTIES)
endfunction()

function(get_source_file_custom_properties SOURCE_FILE)
    string(REGEX REPLACE " " "-" SOURCE_FILE_ID "${SOURCE_FILE}")

    is_map(SOURCE_FILE_${SOURCE_FILE_ID}_CUSTOM_PROPERTIES)
    ans(isset)

    if(NOT isset)
        map_new(SOURCE_FILE_${SOURCE_FILE_ID}_CUSTOM_PROPERTIES)
    endif()

    return(SOURCE_FILE_${SOURCE_FILE_ID}_CUSTOM_PROPERTIES)
endfunction()

function(set_target_custom_property TARGET PROPERTY VALUE)
    get_target_custom_properties(${TARGET})
    ans(map)
    map_set(${map} "${PROPERTY}" "${VALUE}")
endfunction()

function(set_source_file_custom_property TARGET PROPERTY VALUE)
    get_source_file_custom_properties(${TARGET})
    ans(map)
    map_set(${map} "${PROPERTY}" "${VALUE}")
endfunction()

function(get_target_custom_property VARIABLE TARGET PROPERTY)
    get_target_custom_properties(${TARGET})
    ans(map)
    map_get(${map} "${PROPERTY}")
    ans(property)
    set(${VARIABLE} "${property}" PARENT_SCOPE)
endfunction()

function(get_source_file_custom_property VARIABLE TARGET PROPERTY)
    get_source_file_custom_properties(${TARGET})
    ans(map)
    map_get(${map} "${PROPERTY}")
    ans(property)
    set(${VARIABLE} "${property}" PARENT_SCOPE)
endfunction()

function(target_has_custom_property VARIABLE TARGET PROPERTY)
    get_target_custom_properties(${TARGET})
    ans(map)
    map_has(${map} "${PROPERTY}")
    ans(has_property)
    set(${VARIABLE} ${has_property} PARENT_SCOPE)
endfunction()

function(source_file_has_custom_property VARIABLE TARGET PROPERTY)
    get_source_file_custom_properties(${TARGET})
    ans(map)
    map_has(${map} "${PROPERTY}")
    ans(has_property)
    set(${VARIABLE} ${has_property} PARENT_SCOPE)
endfunction()