{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 12,
   "id": "7a35f6ef-6539-48ad-8b3f-1f033c27c322",
   "metadata": {},
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "WARNING: replacing module vSmartMOM.\n"
     ]
    },
    {
     "ename": "LoadError",
     "evalue": "LoadError: UndefVarError: `Architectures` not defined in `Main`\nSuggestion: check for spelling errors or missing imports.\nin expression starting at /Users/jamesyoon/Documents/vSmartMOM.jl/src/CoreRT/CoreRT.jl:9\nin expression starting at /Users/jamesyoon/Documents/vSmartMOM.jl/src/vSmartMOM.jl:9",
     "output_type": "error",
     "traceback": [
      "LoadError: UndefVarError: `Architectures` not defined in `Main`\nSuggestion: check for spelling errors or missing imports.\nin expression starting at /Users/jamesyoon/Documents/vSmartMOM.jl/src/CoreRT/CoreRT.jl:9\nin expression starting at /Users/jamesyoon/Documents/vSmartMOM.jl/src/vSmartMOM.jl:9",
      "",
      "Stacktrace:",
      " [1] include(mod::Module, _path::String)",
      "   @ Base ./Base.jl:557",
      " [2] include(x::String)",
      "   @ Main.vSmartMOM ~/Documents/vSmartMOM.jl/src/vSmartMOM.jl:9",
      " [3] top-level scope",
      "   @ ~/Documents/vSmartMOM.jl/src/vSmartMOM.jl:42",
      " [4] include(fname::String)",
      "   @ Main ./sysimg.jl:38",
      " [5] top-level scope",
      "   @ In[12]:1"
     ]
    }
   ],
   "source": [
    "include(\"src/vSmartMOM.jl\")\n",
    "using vSmartMOM\n",
    "\n",
    "vSmartMOM\n",
    "\n",
    "struct AtmosphericProfile{FT}\n",
    "    lat::FT\n",
    "    lon::FT\n",
    "    psurf::FT\n",
    "    T::Array{FT,1}\n",
    "    q::Array{FT,1}\n",
    "    p::Array{FT,1}\n",
    "    p_levels::Array{FT,1}\n",
    "    vmr_h2o::Array{FT,1}\n",
    "    vcd_dry::Array{FT,1}\n",
    "    vcd_h2o::Array{FT,1}\n",
    "end;"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 9,
   "id": "1bee832e-163c-462c-bc58-ac8d38bb16cf",
   "metadata": {},
   "outputs": [
    {
     "ename": "LoadError",
     "evalue": "UndefVarError: `read_hitran_isoprene` not defined in `Main`\nSuggestion: check for spelling errors or missing imports.",
     "output_type": "error",
     "traceback": [
      "UndefVarError: `read_hitran_isoprene` not defined in `Main`\nSuggestion: check for spelling errors or missing imports.",
      "",
      "Stacktrace:",
      " [1] top-level scope",
      "   @ In[9]:4"
     ]
    }
   ],
   "source": [
    "filepath = \"HITRAN/c5h8_isoprene.101\"\n",
    "ν_min = 890.\n",
    "ν_max = 910.\n",
    "min_strength = 1e-30\n",
    "\n",
    "isoprene_hitran = read_hitran_isoprene(filepath, ν_min = ν_min, ν_max = ν_max, min_strength = min_strength);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "121fff4c-36f4-4346-b882-6054eb2a2679",
   "metadata": {},
   "outputs": [],
   "source": []
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "75e49364-d92a-4353-ade8-b0db074e1309",
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Julia 1.11.2",
   "language": "julia",
   "name": "julia-1.11"
  },
  "language_info": {
   "file_extension": ".jl",
   "mimetype": "application/julia",
   "name": "julia",
   "version": "1.11.2"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
