const { defineConfig, loadEnv } = require("vite");
const react = require("@vitejs/plugin-react");
const { viteSingleFile } = require("vite-plugin-singlefile");

module.exports = ({ mode }) => {
    const env = loadEnv(mode, process.cwd(), "");
    const backend = env.VITE_API_PROXY_TARGET || "http://127.0.0.1:1234";
    return defineConfig({
        plugins: [react(), viteSingleFile()],
        server: {
            proxy: {
                "/sdcpp": backend,
                "/deep-diffusion": backend,
            },
        },
    });
};
