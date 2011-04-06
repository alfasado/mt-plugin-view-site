package ViewSite::Plugin;

use strict;

sub _tmpl_param {
    my ( $cb, $app, $param, $tmpl ) = @_;
    return if ( $app->blog );
    my $website_url = MT->config( 'DefaultWebSiteURL' );
    if (! $website_url ) {
        my $param;
        if ( MT->version_number >= 5 ) {
            $param = { class => 'website' };
        }
        $website_url = MT::Blog->load( $param, { limit => 1 } )->site_url;
    }
    $param->{ website_url } = $website_url;
}

sub _header_source {
    my ( $cb, $app, $tmpl ) = @_;
    my $begin = '<li id="view-site"';
    my $pointer_begin = quotemeta( $begin );
    my $end = '</mt:if>';
    my $pointer_end = quotemeta( $end );
    my $else = <<'MTML';
    <mt:else>
    <li id="view-site" class="nav-link"><a href="<$mt:var name="website_url"$>" title="<__trans phrase="View Site">" target="<__trans phrase="_external_link_target">"><span><__trans phrase="View"></span></a></li>
    </mt:else>
MTML
    $$tmpl =~ s/($pointer_begin.*?)($pointer_end)/$1.$else.$2/esi;
}

sub _cfg_system_general {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $plugin = MT->component( 'ViewSite' );
    my $pointer_field = $tmpl->getElementById( 'system_debug_mode' );
    my $nodeset = $tmpl->createElement( 'app:setting', { id => 'use_minifier',
                                                         label => $plugin->translate( 'Default WebSite URL' ) ,
                                                         show_label => 1,
                                                         content_class => 'field-content-text' } );
    my $innerHTML = <<MTML;
<__trans_section component="ViewSite">
        <input type="text" id="default_website_url" name="default_website_url" value="<mt:var name="default_website_url">" />
</__trans_section>
MTML
    $nodeset->innerHTML( $innerHTML );
    $tmpl->insertBefore( $nodeset, $pointer_field );
    $param->{ default_website_url } = MT->config( 'DefaultWebSiteURL' );
    return 1;
}

sub _pre_run {
    my $app = MT->instance;
    if ( $app->param( '__mode' ) eq 'save_cfg_system_general' ) {
        if (! $app->user->is_superuser ) {
            $app->return_to_dashboard( permission => 1 );
        }
        if ( my $default_website_url = $app->param( 'default_website_url' ) ) {
            my $cfg = $app->config;
            $app->config( 'DefaultWebSiteURL', $default_website_url || undef, 1 );
            $cfg->save_config();
        }
    }
    return 1;
}

1;