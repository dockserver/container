# Container Images

<p align="center">
    <a href="https://discord.gg/FYSvu83caM">
        <img src="https://discord.com/api/guilds/830478558995415100/widget.png?label=Discord%20Server&logo=discord" alt="Join DockServer on Discord">
    </a><br />
    <img src="https://img.shields.io/liberapay/receives/dockserver.svg?logo=liberapay">
    <a href="https://github.com/dockserver/dockserver/releases/latest">
        <img src="https://img.shields.io/github/v/release/dockserver/dockserver?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a></br >
    <a href="https://github.com/dockserver/dockserver/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/dockserver/dockserver?label=License&logo=mit" alt="MIT License">
    </a><br />
    <noscript><a href="https://liberapay.com/dockserver/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a></noscript>
</p>

---
> **Note**:
> All Dockefiles are automatically generated 

> **Note**:
> Do not try to change anything live on the repository

> **Note**:
> All changes are made from our own CI Pipline ( unpublic ) 

---

> **Info**:
> All Containers can be used without breaking.
> You can use all with dockserver

> **Warning**:
> Don't use the images / dockers on other projects
> This should not work for you.

---

## Notice Alpine Builds

1. radarr
1. sonarr
1. sabnzbd
1. lidarr
1. readarr
1. bazarr
1. duplicati
1. And many more......

More and more dockers will use **alpine** as base image


## What that's all ?!

Nope... we have build our own **CI/CD PIPLINE**

It's runs inside of a isolated Container environment 

*(isolated **docker-based** github runner)*

---

The docker-mount and docker-uploader used now
multi-stage builds from our own 
**ALPINE s6-overlay V3 image**

We moved more and more apps in the next few days to S6-overlay V3


---

## Some hidden Updates are pushed

We provide as next some hidden scripts to build

the docker images based of a json / shell file 

Also we have added a new layer for check of any breaches.



Next what is also added :

one dependencies script to pull the latest versions of every dependencies what is used inside of the docker

----

## push to public ?!  And show the code ??

No way ..... 

We didn't show them , 
since I know some other are stealing here,

Without given any credits or respect


--- 

## Ideas and Code

This repository is heavily based on 

[Linuxserver.io](https://linuxserver.io) images and [k8s-at-home](https://k8s-at-home.com/) idea

All Containers have some additional edits just for dockserver.io

Please check before you run it on other systems

---

And the best is 

Fuck XOXO SBOX stealing code to get your product up and running is a bitch move

---

SOME fancy stats 

![metrics](./github-metrics.svg)

---

## Contributors ✨

Thanks goes to these wonderful people

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

### Contributors

<table>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/doob187>
            <img src=https://avatars.githubusercontent.com/u/60312740?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=doob187/>
            <br />
            <sub style="font-size:14px"><b>doob187</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/fscorrupt>
            <img src=https://avatars.githubusercontent.com/u/45659314?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=FSCorrupt/>
            <br />
            <sub style="font-size:14px"><b>FSCorrupt</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/drag0n141>
            <img src=https://avatars.githubusercontent.com/u/44865095?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=DrAg0n141/>
            <br />
            <sub style="font-size:14px"><b>DrAg0n141</b></sub>
        </a>
    </td>
</tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->


