import { getIntersectionRoot } from '@theme/scroll-container';

const SCROLL_TRIGGER_CLASS = 'scroll-trigger';
const OFFSCREEN_CLASS = 'scroll-trigger--offscreen';
const DESIGN_MODE_CLASS = 'scroll-trigger--design-mode';
const CASCADE_SELECTOR = '[data-scroll-reveal-cascade]';

/**
 * @param {ParentNode} rootEl
 */
function decorateCascadeContainers(rootEl) {
  rootEl.querySelectorAll(CASCADE_SELECTOR).forEach((container) => {
    Array.from(container.children).forEach((child, index) => {
      if (child.classList.contains(SCROLL_TRIGGER_CLASS)) return;

      child.classList.add(SCROLL_TRIGGER_CLASS, 'animate--slide-in');

      if (!child.style.getPropertyValue('--animation-order')) {
        child.style.setProperty('--animation-order', String(index + 1));
      }
    });
  });
}

/**
 * @param {IntersectionObserverEntry[]} entries
 * @param {IntersectionObserver} observer
 */
function onIntersection(entries, observer) {
  entries.forEach((entry) => {
    const target = entry.target;
    if (entry.isIntersecting) {
      if (target.classList.contains(OFFSCREEN_CLASS)) {
        target.classList.remove(OFFSCREEN_CLASS);
      }
      observer.unobserve(target);
    } else {
      // Match Dawn: mark offscreen only when the observer reports not intersecting.
      // Do not pre-apply offscreen before observe — that can fight first paint / scroll.
      target.classList.add(OFFSCREEN_CLASS);
    }
  });
}

/**
 * @param {ParentNode} [rootEl]
 * @param {boolean} [isDesignModeEvent]
 */
function initializeScrollReveal(rootEl = document, isDesignModeEvent = false) {
  decorateCascadeContainers(rootEl);

  const elements = rootEl.getElementsByClassName(SCROLL_TRIGGER_CLASS);
  if (!elements.length) return;

  if (isDesignModeEvent) {
    Array.from(elements).forEach((el) => el.classList.add(DESIGN_MODE_CLASS));
    return;
  }

  const observer = new IntersectionObserver(onIntersection, {
    root: getIntersectionRoot(),
    rootMargin: '0px 0px -50px 0px',
  });

  Array.from(elements).forEach((el) => {
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
