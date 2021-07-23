# Copyright 2021 Henrik Jensen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#requires -Version 7

Function FormatS3BucketName([string]$name) {
    [string]$bucketName = $name.ToLower().PadRight(3, '-') -replace('/', '.') -replace('_', '-') -replace '[^a-z0-9\.-]'
    if ($bucketName.length -gt 63) {
        throw "Generated bucket name is longer than 63 character"
    }
    $bucketName
}

Function StripAnsiCharacters([string]$text) {
    [string]$newText = $text -replace '^.*\[\?.*='
    $newText
}

Class ItemsById : System.Collections.Hashtable {
    [void] Add([string]$id, $data) {
        if (!$this.ContainsKey($id)) {
            $this[$id] = @()
        }
        $this[$id] += @( $data )
    }
}
