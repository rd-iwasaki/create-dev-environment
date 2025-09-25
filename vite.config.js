import { defineConfig } from 'vite';

export default defineConfig({
  root: './',
  publicDir: 'public',
  build: {
    outDir: 'public',
    assetsDir: '',
    rollupOptions: {
      input: {
        main: 'src/js/main.js',
        style: 'src/scss/style.scss',
      },
      output: {
        entryFileNames: 'assets/js/[name].js',
        chunkFileNames: 'assets/js/[name].js',
        assetFileNames: 'assets/css/[name].[ext]',
      },
    },
  },
});