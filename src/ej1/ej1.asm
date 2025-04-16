; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat
extern strlen
extern strcpy


string_proc_list_create_asm:
    mov rdi, 16
    call malloc
    test rax, rax
    jz .end
    mov qword [rax], NULL
    mov qword [rax + 8], NULL
.end:
    ret

string_proc_node_create_asm:
    push rbx
    push r12
    mov r12b, dil
    mov rbx, rsi
    mov rdi, 32
    call malloc
    test rax, rax
    jz .end
    mov qword [rax], NULL
    mov qword [rax + 8], NULL
    mov byte [rax + 16], r12b
    mov qword [rax + 24], rbx
.end:
    pop r12
    pop rbx
    ret

string_proc_list_add_node_asm:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13b, sil
    cmp r13b, 8
    jb .check
    mov r13b, 0
.check:
    movzx edi, r13b
    mov rsi, rdx
    call string_proc_node_create_asm
    test rax, rax
    jz .end
    mov rbx, rax
    mov rcx, [r12 + 8]
    test rcx, rcx
    jz .list_empty
    mov [rcx], rax
    mov [rax + 8], rcx
    mov [r12 + 8], rax
    jmp .end
.list_empty:
    mov [r12], rax
    mov [r12 + 8], rax
.end:
    pop r13
    pop r12
    pop rbx
    ret

string_proc_list_concat_asm:
    push rbx
    push r12
    push r13
    push r14
    mov rbx, rdi
    movzx r12, sil
    mov r13, rdx
    test r13, r13
    jz .hash_empty
    mov rdi, r13
    call strlen
    inc rax
    mov rdi, rax
    call malloc
    mov rdi, rax
    mov rsi, r13
    call strcpy
    mov r14, rax
    jmp .check
.hash_empty:
    mov rdi, 1
    call malloc
    mov byte [rax], 0
    mov r14, rax
.check:
    mov r13, [rbx]
    test r13, r13
    jz .end
.loop:
    test r13, r13
    jz .end
    movzx rcx, byte [r13 + 16]
    cmp rcx, r12
    jne .next
    mov rsi, [r13 + 24]
    test rsi, rsi
    jz .next
    mov rdi, rsi
    call strlen
    test rax, rax
    jz .next
    mov rdi, r14
    mov rsi, [r13 + 24]
    call str_concat
    push rax
    mov rdi, r14
    call free
    pop r14
.next:
    mov r13, [r13]
    jmp .loop
.end:
    mov rax, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    ret