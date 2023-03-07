git fetch origin hexo_noise_theme:refs/remotes/origin/hexo_noise_theme

git add -A
git commit --no-edit -m "update"

git rebase origin/hexo_noise_theme

git push origin HEAD:refs/heads/hexo_noise_theme

hexo clean && hexo generate && hexo deploy

pause