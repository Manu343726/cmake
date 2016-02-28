
function(list_dependencies DEPENDENCIES PUBLIC_OUT PRIVATE_OUT INTERFACE_OUT)
    set(current_kind PUBLIC)

    foreach(elem ${DEPENDENCIES})
        if((elem MATCHES "PUBLIC") OR
           (elem MATCHES "PRIVATE") OR
           (elem MATCHES "INTERFACE"))
            set(current_kind ${elem})
        else()
            list(APPEND ${current_kind}_deps ${elem})
        endif()
    endforeach()

    set(${PUBLIC_OUT} ${PUBLIC_deps} PARENT_SCOPE)
    set(${PRIVATE_OUT} ${PRIVATE_deps} PARENT_SCOPE)
    set(${INTERFACE_OUT} ${INTERFACE_deps} PARENT_SCOPE)
endfunction()