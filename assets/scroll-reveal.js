const SCROLL_TRIGGER_CLASS = 'scroll-trigger';
const OFFSCREEN_CLASS = 'scroll-trigger--offscreen';
const DESIGN_MODE_CLASS = 'scroll-trigger--design-mode';

/**
 * @param {IntersectionObserverEntry[]} entries
 * @param {IntersectionObserver} observer
 */
function onIntersection(entries, observer) {
  entries.forEach((entry, index) => {
    const target = entry.target;
    if (entry.isIntersecting) {
      if (target.classList.contains(OFFSCREEN_CLASS)) {
        target.classList.remove(OFFSCREEN_CLASS);
        if (target.hasAttribute('data-cascade')) {
          target.style.setProperty('--animation-order', String(index));
        }
      }
      observer.unobserve(target);
    } else {
      target.classList.add(OFFSCREEN_CLASS);
    }
  });
}

/**
 * @param {ParentNode} [rootEl]
 * @param {boolean} [isDesignModeEvent]
 */
function initializeScrollReveal(rootEl = document, isDesignModeEvent = false) {
  const elements = rootEl.getElementsByClassName(SCROLL_TRIGGER_CLASS);
  if (!elements.length) return;

  if (isDesignModeEvent) {
    Array.from(elements).forEach((el) => el.classList.add(DESIGN_MODE_CLASS));
    return;
  }

  const observer = new IntersectionObserver(onIntersection, {
    rootMargin: '0px 0px -50px 0px',
  });

  Array.from(elements).forEach((el) => {
    el.classList.add(OFFSCREEN_CLASS);
    observer.observe(el);
  });
}

if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
  document.documentElement.classList.add('scroll-reveal--disabled');
} else {
  document.addEventListener('DOMContentLoaded', () => initializeScrollReveal());

  if (typeof Shopify !== 'undefined' && Shopify.designMode) {
    document.addEventListener('shopify:section:load', (event) => {
      initializeScrollReveal(event.target, true);
    });
    document.addEventListener('shopify:section:reorder', () => {
      initializeScrollReveal(document, true);
    });
  }
}
