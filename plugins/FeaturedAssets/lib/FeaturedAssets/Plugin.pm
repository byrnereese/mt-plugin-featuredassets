# Forum Utilities - Movable Type Plugin
# Copyright (C) 2008 Byrne Reese
# Licensed under the same terms as Perl itself

package FeaturedAssets::Plugin;

use strict;

use Carp qw( croak );

sub toggle_featured {
    my $app = shift;
    my $q = $app->param;
    my $id = $q->param('id');
    require MT::Asset;
    my $a = MT::Asset->load($id);
    my $f = 1;
    my $f = !$a->is_featured;
    $a->is_featured($f);
    $a->save;
    return _send_json_response($app, { status => '1', featured => $f });
}

sub _send_json_response {
    my ($app,$result) = @_;
    require JSON;
    my $json = JSON::objToJson( $result );
    $app->send_http_header("");
    $app->print($json);
    return $app->{no_print_body} = 1;
    return undef;
}

sub itemset_feature_asset {
    my ($app) = @_;
    $app->validate_magic or return;

    require MT::Comment;
    require MT::Entry;
    my @comments = $app->param('id');
    for my $comm_id (@comments) {
        my $comm = MT::Comment->load($comm_id) or next;
	if ($comm->is_featured) {
	    $comm->is_featured(0);
	} else {
	    $comm->is_featured(1);
	}
	$comm->save;
	MT->instance->rebuild( Entry => $comm->entry_id );
    }

    $app->add_return_arg( promoted => 1 );
    $app->call_return;
}

sub tag_is_asset_featured {
    my ($ctx, $args, $cond) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_comment_error($ctx->stash('tag'));
    return $a->is_featured;

}

sub xfrm_featured_assets {
    my ($cb, $app, $html_ref) = @_;
  
    $$html_ref =~ s{(<th id="as-file-status")}{<th class="featured"><img src="<mt:var name="static_uri">plugins/FeaturedAssets/images/star-listing.gif" alt="<__trans phrase="Featured">" width="9" height="9" /></th>$1}msg;

    my $html = <<"EOF";
                    <td id="featured-<mt:var name="id">" class="featured <mt:if name="is_featured">yes</mt:if>">
                <mt:if name="is_featured"> 
                        <a href="#" onclick="return toggleFeatured(<mt:var name="id">);"><img src="<mt:var name="static_uri">images/spacer.gif" alt="<__trans phrase="Featured">" width="9" height="9" /></a>
               <mt:else>
                        <a href="#" onclick="return toggleFeatured(<mt:var name="id">);"><img src="<mt:var name="static_uri">images/spacer.gif" alt="<__trans phrase="Not Featured">" width="9" height="9" /></a>
                </mt:if>
                    </td>
EOF

    $$html_ref =~ s{(<td class="si as-file-status)}{$html$1}msg;
    1;
}

sub xfrm_header {
    my ($cb, $app, $html_ref) = @_;
    my $html = <<"EOJS";
  <link rel="stylesheet" href="<mt:var name="static_uri">plugins/FeaturedAssets/css/app.css" type="text/css" />
  <script src="<mt:StaticWebPath>plugins/FeaturedAssets/js/jquery.js"></script>
  <script type="text/javascript">
  function toggleFeatured(id) {
    \$.get("<mt:AdminCGIPath><mt:AdminScript>", {
             '__mode': "toggle_featured_asset",
             'blog_id':"<mt:var name="blog_id">",
             'id':id,
             'magic_token':'<mt:var name="magic_token">'
      },
      function(data){
	  if (data.featured) {
	      \$('#featured-'+id).addClass('yes');
	  } else {
	      \$('#featured-'+id).removeClass('yes');
	  }
      },
      "json"
    );
    return false;
  }
  </script>
EOJS
    $$html_ref =~ s{</head>}{$html</head>}m;
#	if $app->mode eq 'list_comments';
}
1;

