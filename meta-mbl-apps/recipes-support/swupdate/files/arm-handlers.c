#include <stddef.h>
#include "swupdate.h"
#include "handler.h"
#include <rootfs-handler.h>


int rootfsv4_handler_wrapper(struct img_type *img, void *data)
{
    // The actual handler is defined in the swupdate-handlers library built by
    // the swupdate-handlers recipe.
    return rootfsv4_handler(img, data);
}

__attribute__((constructor))
void rootfs_handler_init(void)
{
    register_handler("ROOTFSv4"
                     , rootfsv4_handler_wrapper
                     , IMAGE_HANDLER
                     , NULL);
}
