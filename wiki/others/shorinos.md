## 软件源

- 创建库

    准备好所有编译好的软件包之后，使用 `repo-add` 命令自动读取软件包中的元数据生成 `<源名称>.db.tar.zst`，同时读取文件路径生成 `<源名称>.files.tar.zst`，这是文件本体，为了让 pacman 读取到，需要创建链接或者复制一份，去掉 `.tar.zst` 后缀，最终会有四个文件：`<源名称>.db` `<源名称>.db.tar.zst` `<源名称>.files` `<源名称>.files.tar.zst`。

    示例：

    ```
    repo-add shorin-arch.db.tar.zst shorin-contrib-git-r70.ac80b05-1-any.pkg.tar.zst
    ```
    > 这条命令将 `shorin-contrib-git` 这个包添加到了源里

    生成的文件如下：

    ```
     ls -l 
    lrwxrwxrwx    - shorin 19 6月  21:37 shorin-arch.db -> shorin-arch.db.tar.zst
    .rw-r--r--  718 shorin 19 6月  21:37 shorin-arch.db.tar.zst
    lrwxrwxrwx    - shorin 19 6月  21:37 shorin-arch.files -> shorin-arch.files.tar.zst
    .rw-r--r--  966 shorin 19 6月  21:37 shorin-arch.files.tar.zst
    .rwxr-xr-x 105k shorin 19 6月  20:45 shorin-contrib-git-r70.ac80b05-1-any.pkg.tar.zst
    ```

- 存放和配置

    云存储的 `Public Access` 绑定到 `repo.shorin.xyz`，然后存放上述四个文件和软件包，存放时的目录结构，决定了填入 `pacman.conf` 的链接。例如 `/archlinux/x86_64`，之后填写 `pacman.conf` 的链接就是 `repo.shorin.xyz/archlinux/$arch`。如果源存储在本地目录，那么在填写的时候就是 `file:///path/to/archlinux/$arch` ，注意权限问题。

    >$arch 会自动变成架构，如 `x86_64`，所以软件包实际的存放路径是 `repo.shorin.xyz/archlinux/x86_64/软件包.pkg.tar.zst`

    示例 `pacman.conf` 配置：
    ```
    [shorin-arch]
    SigLevel = Optional TrustAll
    Server = https://repo.shorin.xyz/archlinux/$arch
    ```
    
    >`SigLevel = Optional TrustAll` 代表了不进行验证

- GPG 签名


    `pacman.conf` 中应该默认写了一行 `SigLevel = Required DatabaseOptional`，代表源需要进行安全验证。我们使用 GPG（GNU Privacy Guard）进行此操作。密钥分为私钥和公钥，私钥被密码保护。我们要使用私钥给软件包签名，然后将公钥发布给使用我们源的人，他们在安装包的时候会匹配公钥和软件包上的私钥签名，如果不匹配则验证失败，软件无法安装。

    - 创建密钥对

        ```
        gpg --full-generate-key
        ```
        过程中会让你进行一些选择。`密钥对类型` 选择 `(1) RSA 和 RSA`； `RSA长度` 输入 `4096` 获得最大安全性；`密钥有效期` 按需，`0` 代表永不过期；接下来 `用户标示` 要求填写 `姓名` `邮箱` `对密钥的注释`；最后输入英文字母 `o` 确认，此时会弹出窗口让你设置 `私钥的密码`，此密码用于解码私钥。  

        示例输出：

        ```
        pub   rsa4096 2026-06-19 [SC]
            8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8
        uid                      shorinkiwata (shorin-arch) <example@email.com>
        sub   rsa4096 2026-06-19 [E]
        ```
        
        这一串内容 `8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8` 就是密钥的 ID，代表了这个密钥。

    - 发布公钥

        ```
        gpg --armor --export 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8 > shorin-arch.pub
        ```
        >`--armor` 创建 ASCII 字符封装的输出
        >`--export <密钥 ID >` 导出该 ID 代表的密钥
        >`> shorin-arch.pub` 将命令输出写入 `shorin-arch.pub` 这个文件

        示例输出：

        ```
        -----BEGIN PGP PUBLIC KEY BLOCK-----

        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
        YWFSPCUmvxNLRPo=
        =50Ly
        -----END PGP PUBLIC KEY BLOCK-----
        ```

    - 签名数据库和软件包

        在 `repo-add` 时添加 `--sign --key <密钥 ID >` 选项对生成的数据文件进行签名

        ```
         repo-add --sign --key 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8 shorin-arch.db.tar.zst shorin-contrib-git-r70.ac80b05-1-any.pkg.tar.zst
        ==> 正在将shorin-arch.db.tar.zst提取到临时位置…
        ==> 正在将shorin-arch.files.tar.zst提取到临时位置…
        ==> 正在添加软件包 'shorin-contrib-git-r70.ac80b05-1-any.pkg.tar.zst'
        ==> 警告： 已存在条目 'shorin-contrib-git-r70.ac80b05-1'
        -> 正在计算校验值...
        -> 正在删除现有的条目 'shorin-contrib-git-r70.ac80b05-1'...
        -> 正在创建 'desc' 数据库条目...
        -> 正在创建 'files' 数据库条目...
        ==> 正在生成更新的数据库文件 'shorin-arch.db.tar.zst'
        ==> 正在签名数据库 'shorin-arch.db.tar.zst'...
        -> 已创建签名文件 'shorin-arch.db.tar.zst.sig'
        ==> 正在签名数据库 'shorin-arch.files.tar.zst'...
        -> 已创建签名文件 'shorin-arch.files.tar.zst.sig'
        ```

        除了要对数据库文件签名，还要对软件包签名
    
        ```
        gpg --detach-sign --no-armor shorin-contrib-git-r70.ac80b05-1-any.pkg.tar.zst
        ```
        
        >`--detach-sign` 分离式签名，会额外生成 `.sig` 后缀的文件
        
        >`--no-armor` 不使用 ASCII 字符封装

        现在你的目录看上去会是这样：

        ```
         ls -la
        Permissions Size User   Date Modified Name
        lrwxrwxrwx     - shorin 19 6月  22:13  shorin-arch.db -> shorin-arch.db.tar.zst
        lrwxrwxrwx     - shorin 19 6月  22:13 󱧃 shorin-arch.db.sig -> shorin-arch.db.tar.zst.sig
        .rw-r--r--   717 shorin 19 6月  22:13  shorin-arch.db.tar.zst
        .rw-r--r--   566 shorin 19 6月  22:13 󱧃 shorin-arch.db.tar.zst.sig
        lrwxrwxrwx     - shorin 19 6月  22:13  shorin-arch.files -> shorin-arch.files.tar.zst
        lrwxrwxrwx     - shorin 19 6月  22:13 󱧃 shorin-arch.files.sig -> shorin-arch.files.tar.zst.sig
        .rw-r--r--   966 shorin 19 6月  22:13  shorin-arch.files.tar.zst
        .rw-r--r--   566 shorin 19 6月  22:13 󱧃 shorin-arch.files.tar.zst.sig
        .rwxr-xr-x  105k shorin 19 6月  20:45  shorin-contrib-git-r70.ac80b05-1-any.pkg.tar.zst
        .rw-r--r--   566 shorin 19 6月  22:14 󱧃 shorin-contrib-git-r70.ac80b05-1-any.pkg.tar.zst.sig
        ```
        现在需要上传签名后的文件

    - 发布公钥

        把之前生成的公钥也上传到库里，例如 `repo.shorin.xyz/archlinux/shorin-arch.pub`

        或者传到公钥服务器中

        ```
        gpg --keyserver hkp://keyserver.ubuntu.com --send-keys 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8
        ```
        > 国内连 `hkp://keyserver.ubuntu.com` 可能比较吃力，可以去 `https://keys.openpgp.org/upload` 上传你的公钥，验证邮箱后用 `hkp://keys.openpgp.org` 拉取

    - 导入公钥

        使用源的用户要导入公钥。

        ```
        curl -sO https://repo.shorin.xyz/archlinux/shorin-arch.pub
        sudo pacman-key --add shorin-arch.pub
        sudo pacman-key --lsign-key 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8
        ```
        >先用 `curl` 下载公钥，`-s` 静默拉取，`-O（大写字母O）` 使用服务器上的原始文件名作为本地文件名，默认保存位置在当前目录下；
        
        >然后 `pacman-key --add <公钥文件>`；再用 `--lsign-key (local sign key) <UID>`选项

        >可以使用 `gpg --show-keys shorin-arch.pub` 查看公钥的 ID

        上面这个命令会留下一个 `shorin-arch.pub` 文件，可以通过管道符解决这个问题：

        ```
        curl -s https://repo.shorin.xyz/archlinux/shorin-arch.pub | sudo pacman-key --add -
        sudo pacman-key --lsign-key 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8
        ```
        >`--add` 后面的 `-` 代表读取从管道传入的数据

        如果公钥是传到公钥服务器的，用下面这两条命令下载后本地信任：
        ```
        sudo pacman-key --keyserver hkp://keyserver.ubuntu.com --recv-keys 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8
        sudo pacman-key --lsign-key 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8
        ```

    - 备份密钥对

        > `321备份` 原则，3份数据，2种存储介质，1个异地

        导出私钥

        ```
        gpg --export-secret-keys --armor 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8 > shorin-arch-private-key.asc
        ```

        导出公钥

        ```
        gpg --export --armor 8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8 > shorin-arch-public-key.asc
        ```

        复制 `.rev` 文件（吊销凭证），需要彻底吊销密钥的时候就使用该文件

        ```
        cp ~/.gnupg/openpgp-revocs.d/8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8.rev ./shorin-arch-revocation.rev
        ```

        导入备份

        ```
        gpg --import <文件名>
        ```

## 自动化

