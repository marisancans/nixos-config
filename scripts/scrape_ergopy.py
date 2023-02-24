# https://git.sr.ht/~casper/scrape-ergodox-layout/tree/master/item/scrape.py
# ------------------------------------------------------------------------------
# scrape.py
#
# Scrape an ergodox layout from the ZSA ergodox layout website.
# Because the print button isn't good enough.
# ------------------------------------------------------------------------------

# Constants
URL_TEMPLATE = 'https://configure.zsa.io/ergodox-ez/layouts/{0}'
URL_MINIMUM = URL_TEMPLATE.format('XXXXX')
URL_REGEX = '^https://configure.zsa.io/ergodox-ez/layouts/[A-Za-z0-9]{5,5}/?'
PAGE_LOAD_TIMEOUT = 10 # Seconds
OUTPUT_FILENAME = 'layout.png'
TARGET_ELEMENT = 'ergodox'
EXTRA_HEIGHT = 20 # Pixels
JAVASCRIPT_EXECUTION_TIME = 0.5

# Argument parsing and validation
def main():
    import argparse
    import validators
    import re
    import sys

    try:
        parser = argparse.ArgumentParser(description='Scrape ZSA ergodox layout')
        parser.add_argument('url', help='The URL for your layout. Must look like: \'{0}\', where X is alphanumeric. Append \'/latest/[0-9]\' to select layer.'.format(URL_MINIMUM))
        parser.add_argument('--hide-logo', action='store_true', help='Hide the EZ logo.')
        parser.add_argument('--hide-none-icon', action='store_true', help='Hide the \'none\' icon.')
        parser.add_argument('--hide-mod-color', action='store_true', help='Hide the colored background on modifer keys.')
        parser.add_argument('--darken-key-outlines', action='store_true', help='Darken the key outlines (useful for printing).')

        args = parser.parse_args()

        if not validators.url(args.url):
            raise Exception('URL provided is malformed.')

        if (len(args.url) < len(URL_MINIMUM)
            or re.search(URL_REGEX, args.url) == None):
            raise Exception('URL must look like: \'{0}\', where X is alphanumeric. Append \'/latest/[0-9]\' to select layer.'.format(URL_MINIMUM))

    except Exception as ex:
        print('Error: {0}'.format(ex))
        sys.exit(1)

    scrape(args)

# Program
def scrape(args):
    import os
    import time
    from selenium import webdriver
    from selenium.common.exceptions import TimeoutException
    from selenium.webdriver.common.by import By
    from selenium.webdriver.support.wait import WebDriverWait

    url = args.url
    hide_logo = args.hide_logo
    hide_none_icon = args.hide_none_icon
    hide_mod_color = args.hide_mod_color
    darken_key_outlines = args.darken_key_outlines
    browser = None

    try:
        # NOTE: Using this sad hack because the --width and --height arguments
        # don't work in headless mode on Firefox.
        os.environ['MOZ_HEADLESS_WIDTH'] = '1920'
        os.environ['MOZ_HEADLESS_HEIGHT'] = '1080'

        opts = webdriver.FirefoxOptions()
        opts.add_argument('--headless')
        opts.add_argument('--enable-javascript')

        browser = webdriver.Firefox(options=opts)
        browser.maximize_window()

        browser.get(url)

        print('Waiting for page to load...')

        element = WebDriverWait(browser, timeout=PAGE_LOAD_TIMEOUT).until(lambda b: b.find_element(By.CLASS_NAME, TARGET_ELEMENT))

        # Selenium scrolls down for some reason.
        browser.execute_script('window.scrollTo(0, 0)')
        time.sleep(JAVASCRIPT_EXECUTION_TIME)

        if hide_logo:
            logo = browser.find_element(By.XPATH, '//div[@class=\'ergodox\']/div[@class=\'logo\']')
            browser.execute_script('arguments[0].style.visibility = \'hidden\';', logo)
            time.sleep(JAVASCRIPT_EXECUTION_TIME)

        if hide_none_icon:
            browser.execute_script('document.styleSheets[1].insertRule(".icon-none:before { content: none !important; }")')
            time.sleep(JAVASCRIPT_EXECUTION_TIME)

        if hide_mod_color:
            browser.execute_script('document.styleSheets[1].insertRule(".key.modifier { background-color: rgba(0, 0, 0, 0) !important; }")')
            time.sleep(JAVASCRIPT_EXECUTION_TIME)
            browser.execute_script('document.styleSheets[1].insertRule(".key.magic { background-color: rgba(0, 0, 0, 0) !important; }")')
            time.sleep(JAVASCRIPT_EXECUTION_TIME)

        if darken_key_outlines:
            browser.execute_script('document.styleSheets[1].insertRule(".key { border: 1px solid black !important; }")')
            time.sleep(JAVASCRIPT_EXECUTION_TIME)

        screenshot(browser, element)

    except TimeoutException:
        print ('Page load timed out after {0} seconds. Target element \'{1}\' was not found. Please check whether you have a valid ZSA URL.'.format(PAGE_LOAD_TIMEOUT, TARGET_ELEMENT))

    finally:
        try:
            if not browser is None:
                browser.close()
        except Exception as ex:
            raise Exception from ex

# Save image of element to disk
def screenshot(browser, element):
    import os
    from PIL import Image

    try:
        temp_filename = 'temp.png'

        browser.save_screenshot(temp_filename)

        x0 = (int)(element.location['x'])
        y0 = (int)(element.location['y'])
        x1 = (int)(x0 + element.size['width'])
        # Extra height is added because the visual element extends outside the
        # element's reported borders.
        y1 = (int)(y0 + element.size['height'] + EXTRA_HEIGHT)

        image = Image.open(temp_filename)
        image = image.crop((x0, y0, x1, y1))
        image = image.save(OUTPUT_FILENAME)

        os.remove(temp_filename)

        print('Image saved to: {0}'.format(OUTPUT_FILENAME))

    except Exception as ex:
        raise Exception from ex

# Entry point
if __name__ == '__main__':
    main()
