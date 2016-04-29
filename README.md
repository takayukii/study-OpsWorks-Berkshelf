# Berkshelfを利用したChefレシピの開発

OpsWorksでBerkshelfを利用する際とローカルでBerkshelfを利用する際で構成に違いがあるため個人的に便利な形を整理する。下記が今回落ち着いた形になる。

* BerksfileはCustom Cookbookの上位のフォルダに配置する
* VagrantではCustom Cookbookとberks-cookbooksを直接両方読み込むようにする
* Test Kitchenをうまく動作させるためにCustom CookbookのBerksfileは上位のフォルダのBerksfileを読み込むようにコードを入れる

このリポジトリとBerksfile等の配置方法で下記を両立させる事ができる。

* ローカルでVagrantの環境をプロビジョニングできる
* ローカルでTest Kitchenでプロビジョニングとテストができる
* OpsWorks Chef11でプロビジョニングができる
* OpsWOrks Chef12でプロビジョニングができる

## OpsWorksでBerkshelfを使った時のエラー

OpsWorks Chef11に関しては、Berkshelfで取り込んだCommunity Cookbookによって下記のフォーラムにもあるエラーが発生した。

[opsworks recipes do not work any more](https://forums.aws.amazon.com/thread.jspa?threadID=228072)

>  cannot load such file -- /var/lib/aws/opsworks/cache.stage2/cookbooks/compat_resource/files/lib/compat_resource/gemspec

`iptables`のバージョンを固定する回避策も提示されているが自分の環境の場合効果がなかった。

また、Community Cookbookの[MySQL Cookbook](https://supermarket.chef.io/cookbooks/mysql)に関しては、AmazonLinuxで検証はされているもののOpsWorks Chef11, Chef12ともにエラーが発生し動作できなかった。

## Chef11とChef12について

Chef11の場合はOpsWorks側でBerksfileに記述されたCommunity Cookbookを取得しCustom Cookbookとマージした上でレシピを適用する。Chef12では予め自分でCommunity CookbookをCustom CookbookとともにパッケージしS3にアップロードしておく必要がある（あるいはパッケージしたものと同等の形のリポジトリを作る）。

## ローカルでVagrantの環境をプロビジョニングする

`berks vendor`を実行し、Berksfileに記述されたCookbookをberks-cookbooksにダウンロードする。

Vagrantfileでは下記のようにCustom Cookbookのフォルダとberks-cookbooksを両方読み込みプロビジョニングを行う。

```
  # Chef
  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = ["../", "../berks-cookbooks"]
    chef.add_recipe "vim::default"
    chef.add_recipe "rubydev::default"
    chef.add_recipe "rubydev::mysql"

    chef.json = {
      rvm: {
        user: "root",
        default_ruby: "ruby-2.1",
        user_default_ruby: "ruby-2.1",
        rubies: ["ruby-2.1"]
      },
      mysql: {
        user: "rubydev",
        password: "rubydev",
        database: "rubydev"
      }
    }
  end
```

## ローカルでTest Kitchenでプロビジョニングとテストをする

Custom CookbookのBerksfileを下記のように記述し、上位フォルダのBerksfileを読み込むようにする。

```
source 'https://supermarket.chef.io'

metadata

cookbook = File.dirname(__FILE__)
cookbook.gsub!(/^(.+\/)/, '')

berksfile = '../Berksfile'

contents = File.read(berksfile)
contents.gsub!(/(^\s*source\s*)/, '#\1')
contents.gsub!(/(^\s*metadata\s*)/, '#\1')
contents.gsub!(/(^.*#{cookbook}.*)/, '#\1')

instance_eval(contents)

```

## OpsWorks Chef11でプロビジョニングする

Stackの設定でこのリポジトリを設定し、Manage Berkshelfをオプションで設定することでBerkshelfが利用できる。ただし上記で記載したようにエラーが発生する。NginxのCookbookは動作を確認することができた。

## OpsWorks Chef12でプロビジョニングする

`berks package`でtar.gzの形式にまとめこれをS3にアップロードしリポジトリの代わりに設定する。同じような構成のリポジトリでも設定可能のようだが未検証。

## 所感

Chef12になってCommunity Cookbookを積極的に使っていくような形になっているようにも見受けられるが、如何せん使えるCommunity Cookbook自体が少なく（メンテが活発でなかったり、AmazonLinuxのサポートが怪しかったり）、またOpsWorks自体にハマりどころも多いためやはり積極的に使うのはどうも微妙に感じている。

一方、自分で書いたCookbookをBerkshelfで依存性として利用するという使い方は良さそうに思った。ただ、Chef12ではS3にアップロードするのがとても面倒なので、相応にCookbookが再利用される等のメリットが出るまではリポジトリに並べて管理で良いのではないかと思う。
