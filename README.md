# openglstudy
openglの勉強とか


2015-06-27
test2のやつ、真っ黒で、画像が表示されないです。。

2015-07-03
ローダー関数使うと成功。でもUIImage使うと以前として失敗。切り分けとして、define LOADERすると、
ローダー関数をつかうように、なければ、UIImage使うようにしてみてる。
http://dixq.net/forum/viewtopic.php?f=3&t=15897
ここ参考にしました〜

2015-07-06
複数テクスチャを読み込んで、Uniformでテクスチャユニット番号を指定しても、テクスチャの切り替えがちゃんとなされない。って問題があったのだけど、GLKTextureLoaderより後にglActiveTextureをしていたのが問題だったみたい。
GLTextureLoaderで、vramへの転送もしているだろうと言うところで、想像しておくべきだった。

