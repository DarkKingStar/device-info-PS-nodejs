const { spawn } = require("child_process");

async function run(executable, args, opts = {}) {
    return new Promise((resolve, reject) => {
        const child = spawn(executable, args, {
            shell: true,
            stdio: ["pipe", process.stdout, process.stderr],
            ...opts,
        });

        child.on("error", reject);
        child.on("exit", (code) => {
            if (code === 0) {
                resolve(code);
            } else {
                const e = new Error(`Process exited with error code ${code}`);
                e.code = code;
                reject(e);
            }
        });
    });
}

exports.runPowershellScript= async()=>{
    try {
        console.log("Running child process...");
        await run("powershell", ["-executionpolicy", "unrestricted", "-file", "script.ps1"]);
        console.log("\n\n")
    } catch (e) {
        console.error("Error While running Script: ",e);
        process.exit(e.code || 1);
    }
}