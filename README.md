# Neosky


Neosky is a Neovim plugin that integrates comprehensive social networking features directly into your development environment via Bluesky. This plugin allows developers to interact with social media functionalities such as posting, reposting, liking, unliking, following, unfollowing, and viewing profiles—all without leaving the editor. Additionally, it offers easy scrolling through multiple timelines, making it simple to stay updated across various feeds.

Key features include:

- Full Social Media Interaction: Engage with all essential social media actions directly from Neovim.
- Multiple Timelines Scrolling: Easily scroll through different social media timelines within your editor.
- Seamless Integration: Operates smoothly within the Neovim environment, ensuring uninterrupted coding flow.
- Customizable Interface: Tailor the appearance and functionality of your social interactions within your editor settings.

Designed for developers who wish to stay connected while immersed in coding, Neosky combines robust social media integration with the efficiency of Neovim.


## Installation

I still need to get this right

## dependencies:

I still need to get this right
  - plenary


## Functionality

Neosky transforms Neovim into a powerful social media client with the following features:

- Complete Social Media Operations: Post, repost, like, unlike, follow, unfollow, and view profiles without leaving the editor.
- Effortless Timeline Management: Simultaneously interact with multiple timelines and feeds, such as a game development feed and a personal following feed.
- Neovim Integration: Leverage Neovim’s native capabilities and plugins for enhanced navigation and content management within social feeds.


## Inspiration

The journey to developing Neosky began from a common frustration faced by many developers: the disruption caused by switching between coding and social media. Typically, leaving the Neovim editor to make a quick social media post would unexpectedly turn into a lengthy distraction—about 40 minutes of diverted attention, including the time taken to regain focus on coding tasks. This disruption was compounded by the challenges of managing multiple social media timelines, such as game development and personal following feeds on platforms like Bluesky and atproto.

Inspired by the seamless integration of AI and coding environments in plugins like NeoAI and Codium, which bring advanced functionalities like ChatGPT directly into Neovim, Neosky was envisioned. It aims to integrate extensive social media functionalities within the Neovim environment, allowing developers to interact with social networks without breaking their workflow. This includes posting, scrolling through feeds, and managing multiple timelines, all the while utilizing familiar Neovim mechanics like search, copy-paste, and the integration with other plugins such as Telescope.

## Roadmap

The future of Neosky is aimed at evolving into an autonomous social network built on the atproto standard, tailored specifically for developers. Planned features include support for markdown syntax highlights, capability for longer posts, threaded discussions, and other developer-centric functionalities. This will provide a focused environment conducive to technical discourse and collaboration, minimizing distractions and maximizing productivity.

## Like Minded Plugins

- https://github.com/folke/neodev.nvim
- https://github.com/nanotee/nvim-lua-guide
- https://github.com/rcarriga/nvim-notify
- https://github.com/dgrbrady/nvim-docker

## Contributing

for some reason I need to expand rust stack size to 16 MB otherwise the tokio runtime dies, I'll look at it afterward
  ```bash
    export RUST_MIN_STACK=16777216  # 16 MB
  ```

## Operations

- nuke db
  ```bash
    rm -rf ~/.config/bsky/bsky.db/
  ```
