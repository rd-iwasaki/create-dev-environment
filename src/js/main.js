// Vite環境構築時にインストールした jQuery をインポート
// このimportにより、ViteがjQueryを依存関係として正しく処理します。
import $ from 'jquery';

// -----------------------------------------------------------
// ページ読み込み完了時の処理
// -----------------------------------------------------------
$(document).ready(function() {
    console.log('DOM is fully loaded and ready.');

    // jQueryが正しく動作しているか確認するためのサンプルコード
    const welcomeText = 'jQuery is working! This message is from main.js.';
    
    // public/index.html にある可能性のある要素（例: IDが #app の要素）にテキストを追加
    const targetElement = $('#app');
    
    if (targetElement.length) {
        targetElement.append(`
            <p style="color: green; font-weight: bold;">
                ${welcomeText}
            </p>
        `);
    } else {
        console.warn('Target element #app not found in the DOM.');
    }

    // SCSS（CSS）の変更をホットリロードするサンプル
    // HMR (Hot Module Replacement) の設定
    if (import.meta.hot) {
        import.meta.hot.accept((newModule) => {
            console.log('main.js updated and hot-reloaded.');
        });
    }
});