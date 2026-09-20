<script setup lang="ts">

import {Form} from "@inertiajs/vue3";
import {Input} from "@/components/ui/input";
import Heading from "@/components/Heading.vue";
import {Field, FieldLabel} from "@/components/ui/field";
import {Button} from "@/components/ui/button";
import {uploadFile} from "@/actions/App/Http/Controllers/Files/FilesController";
import {toast} from "vue-sonner";

const success = (data: any)=>{
    const {path} = data.flash;
    toast.success('Successfully uploaded file.', {action: {label: 'Open', onClick: ()=>window.open(`https://content-dev.s3.nl-ams.scw.cloud/${path}`, '_blank')}})
}
</script>

<template>
<div class="p-4">
    <Heading title="Upload file" description="Here you can upload a file." />
    <Form :action="uploadFile()" class="space-y-3" #default="{processing}" @success="success" @error="toast.error('Error uploading your file.')">
        <Field>
            <FieldLabel for="path">Path:</FieldLabel>
            <Input type="text" name="path" />
        </Field>

        <Field>
            <FieldLabel for="file">File:</FieldLabel>
            <Input type="file" name="file" />
        </Field>

        <Button type="submit" :disabled="processing">Upload</Button>
    </Form>
</div>
</template>

<style scoped>

</style>
