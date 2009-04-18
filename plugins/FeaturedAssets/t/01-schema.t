
use lib qw( t/lib lib extlib );

use strict;
use warnings;

use MT::Test qw( :db );
use Test::More tests => 2;

require MT::Asset;
ok (MT::Asset->has_column ('is_featured'), "mt_asset has is_featured column");
ok (MT::Asset->is_meta_column ('is_featured'), "mt_asset's is_featured column is meta");
