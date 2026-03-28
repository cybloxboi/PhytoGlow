{{flutter_js}}
{{flutter_build_config}}

const shell = document.querySelector('.shell');

function detectInAppBrowser() {
  const ua = window.navigator.userAgent || '';
  return /FBAN|FBAV|Instagram|Line\/|Line|MicroMessenger|FB_IAB|Messenger/i.test(ua);
}

function createInAppBanner() {
  const banner = document.createElement('div');
  banner.style.position = 'fixed';
  banner.style.left = '16px';
  banner.style.right = '16px';
  banner.style.bottom = '16px';
  banner.style.zIndex = '9999';
  banner.style.padding = '14px 16px';
  banner.style.borderRadius = '18px';
  banner.style.border = '1px solid rgba(143, 71, 0, 0.18)';
  banner.style.background = 'rgba(255, 248, 241, 0.96)';
  banner.style.boxShadow = '0 16px 30px rgba(143, 71, 0, 0.12)';
  banner.style.backdropFilter = 'blur(12px)';
  banner.style.fontFamily =
    'Manrope, Kanit, "Noto Sans Thai", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif';

  banner.innerHTML = `
    <div style="font-size:14px;font-weight:800;color:#8F4700;">
      ตรวจพบเบราว์เซอร์ภายในแอป
    </div>
    <div style="margin-top:6px;font-size:13px;line-height:1.5;color:#5f5b66;">
      หากหน้านี้แสดงผลไม่สมบูรณ์ กรุณาเปิดลิงก์นี้ใน Chrome, Safari หรือเบราว์เซอร์หลักของคุณ
    </div>
    <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:12px;">
      <button id="open-external-button" type="button"
        style="appearance:none;border:0;border-radius:999px;padding:10px 14px;background:#3F51B5;color:#fff;font:inherit;font-size:13px;font-weight:700;cursor:pointer;">
        เปิดในเบราว์เซอร์
      </button>
      <button id="copy-link-button" type="button"
        style="appearance:none;border:0;border-radius:999px;padding:10px 14px;background:rgba(63, 81, 181, 0.1);color:#3F51B5;font:inherit;font-size:13px;font-weight:700;cursor:pointer;">
        คัดลอกลิงก์
      </button>
    </div>
  `;

  document.body.appendChild(banner);

  const openExternalButton = document.getElementById('open-external-button');
  const copyLinkButton = document.getElementById('copy-link-button');

  if (openExternalButton) {
    openExternalButton.addEventListener('click', () => {
      window.open(window.location.href, '_blank', 'noopener,noreferrer');
    });
  }

  if (copyLinkButton) {
    copyLinkButton.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(window.location.href);
        copyLinkButton.textContent = 'คัดลอกแล้ว';
        window.setTimeout(() => {
          copyLinkButton.textContent = 'คัดลอกลิงก์';
        }, 1800);
      } catch (_) {
        window.prompt('คัดลอกลิงก์นี้', window.location.href);
      }
    });
  }
}

_flutter.loader.load({
  onEntrypointLoaded: async function onEntrypointLoaded(engineInitializer) {
    if (detectInAppBrowser()) {
      createInAppBanner();
    }

    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  },
});
