<?php
/**
 * Helpers for local development.
 *
 * This file may be installed before `mu-plugins` or any PMC code is added to
 * the WordPress instance, so care should be taken to prevent fatal errors when
 * code isn't yet available.
 */

// Ensure AMP is loaded when available, lest fatals stop provisioning.
if (
	function_exists( 'wpcom_vip_load_plugin' )
	&& is_dir( WP_PLUGIN_DIR . '/amp/' )
) {
	wpcom_vip_load_plugin( 'amp' );
}
