${{ content_synopsis }} This image will run minio-console [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md), for maximum security and performance. In addition to being small and secure, it will also automatically create the required user with the required privileges to access minio for you.

${{ content_uvp }} Good question! Because ...

${{ github:> [!IMPORTANT] }}
${{ github:> }}* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
${{ github:> }}* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
${{ github:> }}* ... this image is auto updated to the latest version via CI/CD
${{ github:> }}* ... this image has a health check
${{ github:> }}* ... this image runs read-only
${{ github:> }}* ... this image is automatically scanned for CVEs before and after publishing
${{ github:> }}* ... this image is created via a secure and pinned CI/CD process
${{ github:> }}* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

${{ content_comparison }}

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of policies and config for [mc]
* **${{ json_root }}/ssl** - Directory of SSL certificates used

${{ content_compose }}

${{ content_defaults }}
| `--certs-dir` | ${{ json_root }}/ssl | where to store SSL certificates (if used) |

${{ content_environment }}
| `MINIO_CONSOLE_MINIO_USER` | username of admin user on minio | admin |
| `MINIO_CONSOLE_USER` | username of console user | console |
| `MINIO_CONSOLE_POLICY` | access policy to use (check ${{ json_root }}/etc for available policies) | full |
| `MINIO_CONSOLE_POLICY_NAME` | name of policy on minio | consoleAdmin |
${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}

${{ title_caution }}
${{ github:> [!CAUTION] }}
${{ github:> }}* The compose example uses ```MC_INSECURE```. Never do this in production! Use a valid SSL certificate to terminate your minio!