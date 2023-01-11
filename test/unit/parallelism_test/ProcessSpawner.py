import subprocess
import sys

# argv[0] = Path to this script
# argv[1] = ${CMAKE_COMMAND}
# argv[2] = ${CPM_PATH}
if __name__ == "__main__":
    # CMAKE_BUILD_TYPE of each new CMake process
    processes = ["Debug", "Release"]

    # Spawn the processes
    for i in range(len(processes)):
        command = [sys.argv[1], "-Bparallelism_build_" + processes[i], "-DCPM_PATH=" + sys.argv[2], "-DCMAKE_BUILD_TYPE=" + processes[i]]
        print("Python is executing CMake with the following command: " + " ".join(command))
        processes[i] = subprocess.Popen(command)

    # Wait for each process and throw the exitcode returned by any process with a non-zero exitcode
    for process in processes:
        process.wait()
        if process.returncode != 0:
            exit(process.returncode)
