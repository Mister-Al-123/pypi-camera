<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Dashboard') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="flex p-6 text-gray-900">
                    <div class="ml-2">
                    <iframe src="/live/?controls=false" width="640" height="480"></iframe></div>
                    <div class="ml-2">
                            <div class="pb-2">
                            </div>
                            <div class="pb-2">
                                <p><?php
                                $dir = "/camera";
                                $files = scandir($dir);
                                foreach ($files as $file) {
                                        echo '
                                        <video controls>
                                            <source src="'.$dir.'/'.$file.'" type="video/mp4">
                                        </video>';
                                }
                                    
                                    ?></p>
                            </div>
                            <div class="pb-2">
                                <p>Test text</p>
                            </div>
                    </div>
                </div>
                <div class="ml-2 text-grey-900">
                    <p>Laravel v{{ Illuminate\Foundation\Application::VERSION }} (PHP v{{ PHP_VERSION }})</p>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>

