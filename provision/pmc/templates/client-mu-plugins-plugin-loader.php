<?php
/**
 * Allow themes to load code as part of `mu-plugins`, such as when access to the
 * `plugins_loaded` hook is required.
 *
 * Borrows VIP Go's logic for loading `client-mu-plugins` from
 * `mu-plugins/z-client-mu-plugins.php`, which is what loads this file in the
 * first place.
 */

// Wrap in MU Plugins loaded so pmc-unit-tests has a chance to set the correct theme.
add_action( 'muplugins_loaded', function() {
	$theme_plugins_path = get_stylesheet_directory() . '/client-mu-plugins/';

	if ( wpcom_vip_should_load_plugins() && is_dir( $theme_plugins_path ) ) {
		foreach ( wpcom_vip_get_client_mu_plugins( $theme_plugins_path ) as $client_mu_plugin ) {
			include_once $client_mu_plugin;
		}

		unset( $client_mu_plugin );
	}

	unset( $theme_plugins_path );
} );

/**
 * We use wpcom_vip_load_plugin() in contexts that occur after the
 * `plugins_loaded` action has already fired, which triggers a
 * _doing_it_wrong() message in our logs. We don't plan on changing our
 * approach here, so mute those notices.
 *
 * @param bool   $trigger  Should we log the message?
 * @param string $function Function name this was called from.
 * @param string $message  Message that gets logged.
 * @return bool
 */
function pmc_mute_wpcom_vip_load_plugin_notice( bool $trigger, string $function, string $message ): bool {
	// Check the function that fired this.
	if ( 'wpcom_vip_load_plugin' !== $function ) {
		return $trigger;
	}

	// The function has multiple conditionals for _doing_it_wrong(), so ensure we target the correct one.
	if ( false === strpos( $message, 'plugins_loaded' ) ) {
		return $trigger;
	}

	return false;
}
add_filter( 'doing_it_wrong_trigger_error', 'pmc_mute_wpcom_vip_load_plugin_notice', 10, 3 );
