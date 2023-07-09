# Build

jupyter-book build contents
git add ....
git commit -m '....'
git push github main
cd contents
ghp-import -r github -n -p -f _build/html
