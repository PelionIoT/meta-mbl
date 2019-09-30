import fdt


class DeviceTreeParser:
    def __init__(self, dtb_path):
        self._dev_tree = fdt.parse_dtb(dtb_path.read_bytes())

    def get_node(self, name):
        if not self._dev_tree.exist_node(name):
            raise ValueError(
                "Node with name '{}' does not exist in the device tree."
                .format(name)
            )

        return self._dev_tree.get_node(name)

    def add_node(self, node):
        self._dev_tree.add_item(node)
