# Berkshelfを利用したOpsWorks Chefレシピの開発

OpsWorksでBerkshelfを利用する際とローカルでBerkshelfを利用する際で構成に違いがあるため個人的に整理する。

* BerksfileはCustom Cookbookの上位のフォルダに配置する
* VagrantではCustom Cookbookとberks-cookbooksを直接両方読み込むようにする
* Custom CookbookのBerksfileは上位のフォルダのBerksfileを読み込むようにコードを入れる

このリポジトリとBerksfile等の配置方法で下記を両立させる事ができる。

* ローカルでVagrantの環境をプロビジョニングできる
* ローカルでTest Kitchenでプロビジョニングとテストができる
* OpsWorks Chef11でプロビジョニングができる
* OpsWOrks Chef12でプロビジョニングができる

## プロビジョニング方法

### ローカルでVagrantの環境をプロビジョニングする

`berks vendor`を実行し、Berksfileに記述されたCookbookをberks-cookbooksにダウンロードする。

Vagrantfileでは下記のようにCustom Cookbookのフォルダとberks-cookbooksを両方読み込みプロビジョニングを行う。

```
  # Chef
  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = ['./', './berks-cookbooks']
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

### ローカルでTest Kitchenでプロビジョニングとテストをする

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

### OpsWorks Chef11でプロビジョニングする

Stackの設定でこのリポジトリを設定しManage Berkshelfを有効にする。

### OpsWorks Chef12でプロビジョニングする

`berks package`でtar.gzの形式にまとめこれをS3にアップロードしリポジトリの代わりに設定する。リポジトリの場合は`berks package`の中身と同様であれば動作する。

## OpsWorksでBerkshelfを使った時のエラー

### OpsWorks Chef11のエラー

レシピによって下記のエラーが発生した。

[opsworks recipes do not work any more](https://forums.aws.amazon.com/thread.jspa?threadID=228072)

>  cannot load such file -- /var/lib/aws/opsworks/cache.stage2/cookbooks/compat_resource/files/lib/compat_resource/gemspec

`iptables`のバージョンを固定する回避策も提示されているが自分の環境の場合効果がなかった。

### MySQLのエラー

[MySQL Cookbook](https://supermarket.chef.io/cookbooks/mysql)に関しては、OpsWorks Chef11/12ともにエラーが発生し使えなかった。

## 所感

Community Cookbookは使えるものがあまり多くないわりにハマりどころもあるので少ししんどい印象です。Custom Cookbookを使い回す仕組みとしては良さそう。
