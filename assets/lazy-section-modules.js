/**
 * Loads theme JS module groups when marked sections enter (or near) the viewport.
 * Targets: [data-lazy-section-modules="group-a group-b"]
 */

/** @type {Set<string>} */
const loadedGroups = new Set();

/** @type {Record<string, string[]>} */
const moduleGroups = (() => {
  const node = document.getElementById('lazy-section-module-groups');
  if (!node?.textContent) return {};

  try {
    return JSON.parse(node.textContent);
  } catch {
    return {};
  }
})();

/**
 * @param {string} url
 */
function loadModuleScript(url) {
  if (document.querySelector(`script[data-lazy-module="${url}"]`)) {
    return Promise.resolve();
  }

  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.type = 'module';
    script.src = url;
    script.dataset.lazyModule = url;
    script.fetchPriority = 'low';
    script.onload = () => resolve();
    script.onerror = () => reject(new Error(`Failed to load ${url}`));
    document.head.appendChild(script);
  });
}

/**
 * @param {string} groupName
 */
async function loadModuleGroup(groupName) {
  if (loadedGroups.has(groupName)) return;
  loadedGroups.add(groupName);

  const urls = moduleGroups[groupName];
  if (!urls?.length) return;

  await Promise.all(urls.map((url) => loadModuleScript(url)));
}

/**
 * @param {Element} target
 */
function loadModulesForTarget(target) {
  const groupNames = target.dataset.lazySectionModules?.split(/\s+/).filter(Boolean) ?? [];

  for (const groupName of groupNames) {
    loadModuleGroup(groupName);
  }
}

const observer = new IntersectionObserver(
  (entries) => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;

      loadModulesForTarget(entry.target);
      observer.unobserve(entry.target);
    }
  },
  { rootMargin: '200px 0px' }
);

function observeLazySectionTargets() {
  document.querySelectorAll('[data-lazy-section-modules]').forEach((target) => {
    if (!(target instanceof Element)) return;

    if (target.getBoundingClientRect().bottom >= -200 && target.getBoundingClientRect().top <= window.innerHeight + 200) {
      loadModulesForTarget(target);
      return;
    }

    observer.observe(target);
  });
}

observeLazySectionTargets();
document.addEventListener('shopify:section:load', observeLazySectionTargets);
