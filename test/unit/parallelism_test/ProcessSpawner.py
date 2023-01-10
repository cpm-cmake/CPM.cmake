import time, subprocess, sys

# argv[0] = Path to this script
# argv[1] = ${CMAKE_COMMAND}
# argv[2] = ${CPM_PATH}
if __name__ == "__main__":
    processes = ["Debug", "Release"]
    for i in range(len(processes)):
        command = [sys.argv[1], "-Bparallelism_build_" + processes[i], "-DCPM_PATH=" + sys.argv[2], "-DCMAKE_BUILD_TYPE=" + processes[i]]
        print("Python is executing CMake with the following command: " + " ".join(command))
        processes[i] = subprocess.Popen(command)
    for process in processes:
        process.wait()
        if process.returncode != 0:
            exit(process.returncode)
