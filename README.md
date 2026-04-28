# Personal Website

This is my personal static website built with [Hugo](https://gohugo.io/), a fast and flexible static site generator written in Go.

## Getting Started

### Prerequisites

- [Hugo](https://gohugo.io/getting-started/installing/) installed (version 0.80 or newer recommended)

### Running the Site Locally

```sh
hugo server
```

Visit [http://localhost:1313/](http://localhost:1313/)
in your browser to view the site.

### Building for Production

```sh
hugo
```

The generated static files will be in the `public/` directory.

## Customization

- Content: Add or edit content in the `content/` directory.
- Themes: Change or update your theme in the `themes/` directory and `config.toml`.

## Deployment

You can deploy the contents of the `public/` directory to any static hosting provider (Netlify, Vercel, GitHub Pages, etc.).
