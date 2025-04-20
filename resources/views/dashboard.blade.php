<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Dashboard') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 text-gray-900">
                    <p class="text-4xl font-extrabold">
                        Stream
                    </p>
                    <div class="ml-2">
                        <iframe src="/live/?controls=false" width="640" height="480"></iframe>
                    </div>
                    <div>
                        <p class="text-4xl font-extrabold">
                            Clips
                        </p>
                        <?php
                            $dir = "/camera";
                            $files = array_diff(scandir($dir), array('.', '..'));
                            $files = array_reverse($files);
                            foreach ($files as $file) {
                                    $filename = "$file";
                                    echo '
                                    <div class="flex p-4 shadow-sm sm:rounded-lg bg-slate-300">
                                        <video width="320" height="240" controls>
                                            <source src="'.$dir.'/'.$file.'" type="video/mp4">
                                        </video>
                                        <p class="ml-2 text-2xl font-extrabold">
                                            '.$filename.'
                                        </p class="p-6 flex">
                                        <p> Button </p>
                                    </div>
                                    ';
                            }           
                        ?>
                    </div>
                </div>
                <div class="ml-2 text-grey-900">
                    <p>Laravel v{{ Illuminate\Foundation\Application::VERSION }} (PHP v{{ PHP_VERSION }})</p>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>

