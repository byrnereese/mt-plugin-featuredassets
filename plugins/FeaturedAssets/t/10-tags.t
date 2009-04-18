
use lib qw( t/lib lib extlib );

use strict;
use warnings;

use MT::Test qw( :db :data );
use Test::More qw(no_plan);

require MT::Asset;
my $asset = MT::Asset->load(1);

ok( !$asset->is_featured, "Asset #1 is not featured" );

tmpl_out_like(
    '<mt:assetisfeatured>Featured!<mt:else>Not!</mt:assetisfeatured>',
    {},
    { asset => $asset },
    qr/^Not!$/,
    "mt:assetisfeatured is false for a non-featured asset"
);

$asset->is_featured(1);

tmpl_out_like(
    '<mt:assetisfeatured>Featured!<mt:else>Not!</mt:assetisfeatured>',
    {},
    { asset => $asset },
    qr/^Featured!$/,
    "mt:assetisfeatured is true for a featured asset"
);
