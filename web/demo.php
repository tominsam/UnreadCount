
<h2>Unread Count Tracking</h2>

<?php

# change this, obviously
$base = "/home/tomi/Github/UnreadCount/";


# incidentally, I'm no good at PHP. Never done any before. This script works, it's just a demo. Eh.

function graphUrl($name) {
  global $base;
  $filename = $base . $name . ".txt";

  $list = file($filename, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

  # limit to 200 entries (about 10 days)
  if (count($list) > 200) {
    $list = array_slice( $list, -200 );
  }

  $max = max($list);
  $last = $list[ count($list) - 1 ];

  // scale values from 0-100 (ewwww) then trim to 2dp
  for ($i=0; $i<count($list); $i++) {
    $percent = 100 * ((double)$list[$i] / $max);
    $list[$i] = sprintf("%0.2f", $percent);
  }

  $image = "http://chart.apis.google.com/chart?";
  $image .= "&cht=lc"; // line
  $image .= "&chs=250x50"; // size
  $image .= "&chco=0077CC"; // color
  $image .= "&chls=1.5,1,0"; // line style
  $image .= "&chm=B,E6F2FA,0,0,0|o,990000,0," . count($list) . ",4"; // final point
  $image .= "&chxt=r,x,y"; // axis labels
  $image .= "&chxs=0,990000,11,0,_|1,990000,1,0,_|2,990000,1,0,_"; // label formatting
  $image .= "&chxl=0:|" . $last . "|1:||2:||"; // labels
  $image .= "&chxp=0," . $list[ count($list) - 1 ]; // height of label
  $image .= "&chd=t:";
  foreach (array_slice($list,1) as $l) {
    $image .= $l . ",";
  }
  $image .= $list[ count($list) - 1 ];
  
  #error_log($image);
  return $image;
}
?>

<table>
<tr>
  <td>instapaper unread items</td><td><img src="<?php print graphUrl("instapaper") ?>"></td>
</tr>
<tr>
  <td>inbox total size</td><td><img src="<?php print graphUrl("imap") ?>"></td>
</tr>
<tr>
  <td>google reader unread items</td><td><img src="<?php print graphUrl("reader") ?>"></td>
</tr>
</table>
