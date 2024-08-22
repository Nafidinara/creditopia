<template>
  <div class="flex items-center bg-[#838386] bg-opacity-45 rounded">
    <div class="h-[42px] w-[95px] flex items-center justify-center rounded cursor-pointer" v-for="item in items"
      :key="item"
      :class="item === props.value ? ['text-black bg-white'] : ['text-[#838386]']" @click="onChange(item)">{{ item }}
    </div>
  </div>
</template>

<script setup>
const emits = defineEmits(['onChange'])
const props = defineProps({
  value: {
    type: String,
    default: "0"
  },
  items: {
    type: Array,
    default: () => []
  }
});

const onChange = (value) => {
  emits("onChange", value)
};
</script>