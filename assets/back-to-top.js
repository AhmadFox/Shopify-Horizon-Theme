import { Component } from '@theme/component';

/**
 * Scrolls the page to the top without changing the URL hash.
 *
 * @extends {Component}
 */
class BackToTopComponent extends Component {
  /**
   * @param {Event} [event]
   */
  scrollToTop = (event) => {
    event?.preventDefault();

    const pageWrapper = document.querySelector('.page-wrapper');
    const scrollOptions = { top: 0, left: 0, behavior: /** @type {ScrollBehavior} */ ('smooth') };

    if (pageWrapper instanceof HTMLElement) {
      pageWrapper.scrollTo(scrollOptions);
    }

    window.scrollTo(scrollOptions);
  };
}

if (!customElements.get('back-to-top-component')) {
  customElements.define('back-to-top-component', BackToTopComponent);
}
